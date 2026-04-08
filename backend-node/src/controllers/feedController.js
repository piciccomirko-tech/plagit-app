const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');

// Helper: create a feed notification (fire-and-forget)
async function notify(recipientId, actorId, actionType, postId, preview) {
  if (recipientId === actorId) return; // Don't notify yourself
  try {
    await db('feed_notifications').insert({
      recipient_id: recipientId, actor_id: actorId,
      action_type: actionType, post_id: postId || null,
      preview: preview ? preview.slice(0, 120) : null,
    });
  } catch (e) { /* table might not exist yet, ignore */ }
}

// ---------------------------------------------------------------------------
// Helper: build post row with author info
// ---------------------------------------------------------------------------
function postSelect() {
  return db('feed_posts')
    .leftJoin('users', 'feed_posts.user_id', 'users.id')
    .leftJoin('candidates', function () {
      this.on('users.id', '=', 'candidates.user_id').andOn('users.user_type', '=', db.raw("'candidate'"));
    })
    .leftJoin('businesses', function () {
      this.on('users.id', '=', 'businesses.user_id').andOn('users.user_type', '=', db.raw("'business'"));
    })
    .where('feed_posts.status', 'active');
}

const POST_COLUMNS = [
  'feed_posts.id', 'feed_posts.body', 'feed_posts.image_url', 'feed_posts.video_url', 'feed_posts.location',
  'feed_posts.tag', 'feed_posts.role_category', 'feed_posts.like_count', 'feed_posts.comment_count',
  'feed_posts.view_count', 'feed_posts.save_count',
  'feed_posts.latitude', 'feed_posts.longitude', 'feed_posts.created_at',
  'feed_posts.user_id',
  'users.name as author_name', 'users.user_type as author_type',
  'users.photo_url as author_photo_url', 'users.avatar_hue as author_avatar_hue',
  'users.is_verified as author_verified',
  db.raw("COALESCE(candidates.role, businesses.name) as author_subtitle"),
  db.raw("COALESCE(candidates.location, businesses.location, users.location) as author_location"),
  db.raw("COALESCE(candidates.initials, businesses.initials, LEFT(users.name, 2)) as author_initials"),
  db.raw("candidates.nationality as author_nationality"),
  db.raw("candidates.nationality_code as author_nationality_code"),
  db.raw("COALESCE(candidates.country_code, businesses.country_code) as author_country_code"),
];

// ---------------------------------------------------------------------------
// GET /feed — List feed posts
// ---------------------------------------------------------------------------
async function listPosts(req, res, next) {
  try {
    const { page = 1, limit = 20, tag, role, tab } = req.query;
    const userId = req.user.id;

    let base = postSelect();

    if (tag) base = base.where('feed_posts.tag', tag);
    if (role) base = base.whereILike('feed_posts.role_category', `%${role}%`);

    // Tab handling
    if (tab === 'following') {
      const followedIds = await db('user_follows').where({ follower_id: userId }).select('followed_id').then(r => r.map(f => f.followed_id));
      if (followedIds.length > 0) {
        base = base.whereIn('feed_posts.user_id', followedIds);
      } else {
        // Not following anyone — return empty
        paginated(res, [], { page: +page, limit: +limit, total: 0 });
        return;
      }
    }

    if (tab === 'nearby') {
      const user = await db('users').where({ id: userId }).select('latitude', 'longitude').first();
      if (user?.latitude && user?.longitude) {
        base = base
          .whereNotNull('feed_posts.latitude')
          .whereNotNull('feed_posts.longitude')
          .whereRaw(`(6371 * acos(LEAST(1.0, cos(radians(?)) * cos(radians(feed_posts.latitude)) * cos(radians(feed_posts.longitude) - radians(?)) + sin(radians(?)) * sin(radians(feed_posts.latitude))))) <= 50`,
            [user.latitude, user.longitude, user.latitude]);
      }
    }

    const total = await base.clone().count('feed_posts.id as c').first().then(r => +r.c);
    const rows = await base.clone()
      .select(POST_COLUMNS)
      .orderBy('feed_posts.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);

    // Attach media, liked-by-me, and following flags
    const myFollows = await db('user_follows').where({ follower_id: userId }).select('followed_id').then(r => new Set(r.map(f => f.followed_id)));
    for (const row of rows) {
      // Attach media array (new multi-media, falls back to legacy image_url/video_url)
      const media = await db('post_media').where({ post_id: row.id }).orderBy('sort_order').select('id', 'media_type', 'url', 'sort_order');
      if (media.length > 0) {
        row.media = media;
      } else if (row.image_url || row.video_url) {
        // Legacy single-media compat
        row.media = [];
        if (row.image_url) row.media.push({ id: row.id + '-img', media_type: 'photo', url: row.image_url, sort_order: 0 });
        if (row.video_url) row.media.push({ id: row.id + '-vid', media_type: 'video', url: row.video_url, sort_order: 1 });
      } else {
        row.media = [];
      }
    }
    const mySaves = await db('post_saves').where({ user_id: userId }).select('post_id').then(r => new Set(r.map(s => s.post_id)));
    for (const row of rows) {
      const liked = await db('post_likes').where({ post_id: row.id, user_id: userId }).first();
      row.is_liked = !!liked;
      row.is_saved = mySaves.has(row.id);
      row.is_following = row.user_id ? myFollows.has(row.user_id) : false;
      row.is_own = row.user_id === userId;
    }

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed — Create a new post
// ---------------------------------------------------------------------------
async function createPost(req, res, next) {
  try {
    const userId = req.user.id;
    const { body, image_url, video_url, media, location, tag, role_category, latitude, longitude } = req.body;
    if (!body || !body.trim()) throw AppError.badRequest('Post body is required.');

    // Legacy single-media compat
    if (image_url && image_url.length > 4 * 1024 * 1024) throw AppError.badRequest('Image too large.');
    const processedVideoUrl = video_url && video_url.startsWith('data:video/') && video_url.length > 10 * 1024 * 1024 ? null : (video_url || null);

    const [post] = await db('feed_posts').insert({
      user_id: userId, body: body.trim(),
      image_url: image_url || null, video_url: processedVideoUrl, location: location || null,
      tag: tag || null, role_category: role_category || null,
      latitude: latitude || null, longitude: longitude || null,
    }).returning('*');

    // Insert multi-media items if provided
    const mediaItems = [];
    if (Array.isArray(media) && media.length > 0) {
      for (let i = 0; i < Math.min(media.length, 5); i++) {
        const m = media[i];
        if (m.url && m.media_type) {
          const [row] = await db('post_media').insert({
            post_id: post.id, media_type: m.media_type, url: m.url, sort_order: i,
          }).returning('*');
          mediaItems.push(row);
        }
      }
    }

    const full = await postSelect().where('feed_posts.id', post.id).select(POST_COLUMNS).first();
    full.is_liked = false;
    full.is_following = false;
    full.is_own = true;
    full.media = mediaItems.length > 0 ? mediaItems : (
      image_url ? [{ id: post.id + '-img', media_type: 'photo', url: image_url, sort_order: 0 }] :
      processedVideoUrl ? [{ id: post.id + '-vid', media_type: 'video', url: processedVideoUrl, sort_order: 0 }] : []
    );
    ok(res, full);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/:id/like — Toggle like
// ---------------------------------------------------------------------------
async function toggleLike(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;

    const existing = await db('post_likes').where({ post_id: postId, user_id: userId }).first();
    if (existing) {
      await db('post_likes').where({ id: existing.id }).del();
      await db('feed_posts').where({ id: postId }).decrement('like_count', 1);
      ok(res, { liked: false });
    } else {
      await db('post_likes').insert({ post_id: postId, user_id: userId });
      await db('feed_posts').where({ id: postId }).increment('like_count', 1);
      // Notify post author
      const post = await db('feed_posts').where({ id: postId }).select('user_id', 'body').first();
      if (post) notify(post.user_id, userId, 'like', postId, post.body);
      ok(res, { liked: true });
    }
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /feed/:id/comments — List comments
// ---------------------------------------------------------------------------
async function listComments(req, res, next) {
  try {
    const postId = req.params.id;
    const { page = 1, limit = 50 } = req.query;
    const total = await db('post_comments').where({ post_id: postId }).count('* as c').first().then(r => +r.c);
    const rows = await db('post_comments')
      .leftJoin('users', 'post_comments.user_id', 'users.id')
      .leftJoin('candidates', function () {
        this.on('users.id', '=', 'candidates.user_id').andOn('users.user_type', '=', db.raw("'candidate'"));
      })
      .leftJoin('businesses', function () {
        this.on('users.id', '=', 'businesses.user_id').andOn('users.user_type', '=', db.raw("'business'"));
      })
      .where('post_comments.post_id', postId)
      .select(
        'post_comments.id', 'post_comments.body', 'post_comments.created_at',
        'post_comments.user_id',
        'users.name as author_name', 'users.user_type as author_type',
        'users.photo_url as author_photo_url', 'users.avatar_hue as author_avatar_hue',
        'users.is_verified as author_verified',
        db.raw("COALESCE(candidates.initials, businesses.initials, LEFT(users.name, 2)) as author_initials"),
      )
      .orderBy('post_comments.created_at', 'asc')
      .limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/:id/comments — Add comment
// ---------------------------------------------------------------------------
async function addComment(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const { body } = req.body;
    if (!body || !body.trim()) throw AppError.badRequest('Comment body is required.');

    const [comment] = await db('post_comments').insert({
      post_id: postId, user_id: userId, body: body.trim(),
    }).returning('*');

    await db('feed_posts').where({ id: postId }).increment('comment_count', 1);

    // Notify post author
    const post = await db('feed_posts').where({ id: postId }).select('user_id').first();
    if (post) notify(post.user_id, userId, 'comment', postId, body.trim());

    // Return with author info
    const user = await db('users').where({ id: userId }).first();
    const cand = await db('candidates').where({ user_id: userId }).first();
    const biz = await db('businesses').where({ user_id: userId }).first();

    ok(res, {
      id: comment.id, body: comment.body, created_at: comment.created_at,
      user_id: userId,
      author_name: user.name, author_type: user.user_type,
      author_photo_url: user.photo_url, author_avatar_hue: user.avatar_hue,
      author_verified: user.is_verified,
      author_initials: cand?.initials || biz?.initials || user.name.slice(0, 2).toUpperCase(),
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /feed/:id — Delete own post
// ---------------------------------------------------------------------------
async function deletePost(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const post = await db('feed_posts').where({ id: postId, user_id: userId }).first();
    if (!post) throw AppError.notFound('Post not found or not yours.');
    await db('feed_posts').where({ id: postId }).update({ status: 'deleted', updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/seed — One-time seed for demo data (idempotent)
// ---------------------------------------------------------------------------
async function seedFeed(req, res, next) {
  try {
    const existing = await db('feed_posts').count('* as c').first();
    if (+existing.c > 0) { ok(res, { message: 'Already seeded', count: +existing.c }); return; }

    // Get real users from DB
    const candidates = await db('users').where({ user_type: 'candidate', status: 'active' }).select('id').limit(8);
    const businesses = await db('users').where({ user_type: 'business', status: 'active' }).select('id').limit(6);
    if (candidates.length === 0 && businesses.length === 0) { ok(res, { message: 'No users to seed from' }); return; }

    function h(hours) { return new Date(Date.now() - hours * 3600000).toISOString(); }
    const c = candidates.map(u => u.id);
    const b = businesses.map(u => u.id);

    const posts = [
      { user_id: c[0] || b[0], body: "Just finished a 14-hour double shift and still managed to plate 200+ covers without sending back a single dish. That's what 8 years in fine dining does to you.\n\nIf you're looking for a Head Chef who can handle pressure, my DMs are open.", tag: 'open_to_work', role_category: 'chef', location: 'London, UK', latitude: 51.5074, longitude: -0.1278, like_count: 47, comment_count: 3, created_at: h(2) },
      { user_id: b[0] || c[0], body: "We're expanding our London team! Looking for passionate chefs and experienced waitstaff who want to be part of something special.\n\nCompetitive salary, world-class training. Apply through Plagit or DM us.", tag: 'hiring', role_category: 'chef', location: 'Mayfair, London', latitude: 51.5099, longitude: -0.1496, like_count: 82, comment_count: 5, created_at: h(3) },
      { user_id: c[1] || c[0] || b[0], body: "Quick tip for bartenders doing interviews: always ask about the cocktail menu and suggest one improvement. Shows initiative and knowledge.\n\nLanded my current role exactly like this.", role_category: 'bartender', location: 'London, UK', latitude: 51.5155, longitude: -0.0834, like_count: 93, comment_count: 4, created_at: h(5) },
      { user_id: b[1] || b[0] || c[0], body: "Proud to announce that three of our team members have been promoted this quarter. We believe in growing talent from within.\n\nCurrently looking for a Front of House Manager to join our team. Must have 5+ years luxury hospitality experience.", tag: 'hiring', role_category: 'manager', location: 'Piccadilly, London', latitude: 51.5071, longitude: -0.1413, like_count: 64, comment_count: 2, created_at: h(7) },
      { user_id: c[2] || c[0] || b[0], body: "Moved to London 6 months ago. Best decision I ever made. The hospitality scene here is incredible — so many opportunities if you're willing to work hard.\n\nCurrently working as a sommelier at a Michelin-starred restaurant and loving every minute.", tag: 'open_to_work', role_category: 'waiter', location: 'Soho, London', latitude: 51.5136, longitude: -0.1365, like_count: 56, comment_count: 3, created_at: h(10) },
      { user_id: b[2] || b[0] || c[0], body: "Our kitchen team just won 'Best Casual Dining Kitchen' at the London Restaurant Awards! So proud of every single person.\n\nWe're hiring kitchen porters and line cooks. No ego, just great food and great people.", tag: 'hiring', role_category: 'kitchen_porter', location: 'Soho, London', latitude: 51.5133, longitude: -0.1315, like_count: 121, comment_count: 6, created_at: h(12) },
      { user_id: c[3] || c[0] || b[0], body: "After 3 years of working doubles, I finally got my first management position. Started as a runner, worked my way up to floor manager.\n\nNever let anyone tell you hospitality isn't a real career.", role_category: 'manager', location: 'Shoreditch, London', latitude: 51.5242, longitude: -0.0775, like_count: 178, comment_count: 8, created_at: h(15) },
      { user_id: c[4] || c[0] || b[0], body: "Available for shifts this weekend! Trained barista and waitress with 4 years experience. Based in East London but happy to travel.\n\nReliable, fast learner, great with customers. References available.", tag: 'available_for_shifts', role_category: 'waiter', location: 'East London', latitude: 51.5321, longitude: -0.0515, like_count: 23, comment_count: 1, created_at: h(18) },
      { user_id: b[3] || b[0] || c[0], body: "Sunset service at 40 floors up. There's nothing quite like it.\n\nWe're looking for experienced bartenders who can craft cocktails with a view. Must be comfortable with high-volume service and VIP clientele.", tag: 'looking_for_staff', role_category: 'bartender', location: 'Tower Bridge, London', latitude: 51.5055, longitude: -0.0754, like_count: 95, comment_count: 3, created_at: h(20) },
      { user_id: c[5] || c[0] || b[0], body: "Does anyone else feel like the industry is finally starting to take work-life balance seriously? More restaurants offering 4-day weeks, proper breaks, mental health support.\n\nIt's about time. Burnout is real in this industry.", role_category: 'chef', location: 'Camden, London', latitude: 51.5390, longitude: -0.1426, like_count: 234, comment_count: 10, created_at: h(24) },
      { user_id: c[6] || c[0] || b[0], body: "Just completed my Level 3 Food Safety certification!\n\nInvesting in yourself is the best thing you can do in this industry.", role_category: 'waiter', location: 'Canary Wharf, London', latitude: 51.5054, longitude: -0.0235, like_count: 67, comment_count: 2, created_at: h(30) },
      { user_id: b[4] || b[0] || c[0], body: "We don't just hire staff — we build careers. Our graduate programme has a 94% retention rate.\n\nNow accepting applications for our 2026 intake across all departments.", tag: 'hiring', role_category: 'reception', location: 'Park Lane, London', latitude: 51.5040, longitude: -0.1505, like_count: 88, comment_count: 3, created_at: h(36) },
      { user_id: c[7] || c[0] || b[0], body: "Looking for a Head Chef position in Central London. 10 years experience across fine dining, casual, and hotel restaurants.\n\nHappy to do a trial shift. Let's connect!", tag: 'open_to_work', role_category: 'chef', location: 'Central London', latitude: 51.5099, longitude: -0.1337, like_count: 41, comment_count: 2, created_at: h(42) },
      { user_id: b[5] || b[0] || c[0], body: "Our events team is growing! We need experienced bartenders and floor staff for the summer season.\n\nFlexible shifts available — perfect if you're studying or have another job.", tag: 'looking_for_staff', role_category: 'bartender', location: 'Farringdon, London', latitude: 51.5200, longitude: -0.1052, like_count: 53, comment_count: 1, created_at: h(48) },
      { user_id: c[0] || b[0], body: "Pro tip for anyone doing a kitchen trial: arrive 15 minutes early, bring your own knives (sharpened), and always say 'yes chef'.\n\nWhat's your best interview/trial tip?", role_category: 'chef', location: 'London, UK', latitude: 51.5074, longitude: -0.1278, like_count: 112, comment_count: 5, created_at: h(52) },
    ];

    const inserted = [];
    for (const post of posts) {
      const [row] = await db('feed_posts').insert(post).returning('*');
      inserted.push(row);
    }

    // Add some comments
    const allUsers = [...c, ...b].filter(Boolean);
    const commentTexts = [
      "This is so true! Respect.",
      "Love to see this. Well done!",
      "We'd love to chat. Send your CV!",
      "Great advice, doing this in my next interview.",
      "The hospitality industry needs more of this energy.",
      "Congrats! Hard work pays off.",
      "Amazing opportunity. Applied!",
      "This is what separates good from great.",
    ];
    for (const post of inserted) {
      const numComments = Math.min(post.comment_count, allUsers.length);
      for (let i = 0; i < numComments; i++) {
        const uid = allUsers[(i + inserted.indexOf(post)) % allUsers.length];
        if (uid !== post.user_id) {
          try {
            await db('post_comments').insert({
              post_id: post.id, user_id: uid,
              body: commentTexts[(i + inserted.indexOf(post)) % commentTexts.length],
            });
          } catch (e) { /* skip */ }
        }
      }
    }

    // Add likes
    for (const post of inserted) {
      const likers = allUsers.filter(() => Math.random() < 0.4).filter(uid => uid !== post.user_id);
      for (const uid of likers) {
        try { await db('post_likes').insert({ post_id: post.id, user_id: uid }); } catch (e) { /* dup */ }
      }
    }

    ok(res, { message: 'Seeded', posts: inserted.length });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/follow/:userId — Follow a user
// ---------------------------------------------------------------------------
async function followUser(req, res, next) {
  try {
    const followerId = req.user.id;
    const followedId = req.params.userId;
    if (followerId === followedId) throw AppError.badRequest('Cannot follow yourself.');
    const existing = await db('user_follows').where({ follower_id: followerId, followed_id: followedId }).first();
    if (!existing) {
      await db('user_follows').insert({ follower_id: followerId, followed_id: followedId });
      notify(followedId, followerId, 'follow', null, null);
    }
    ok(res, { following: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /feed/follow/:userId — Unfollow a user
// ---------------------------------------------------------------------------
async function unfollowUser(req, res, next) {
  try {
    const followerId = req.user.id;
    const followedId = req.params.userId;
    await db('user_follows').where({ follower_id: followerId, followed_id: followedId }).del();
    ok(res, { following: false });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /feed/following — List users I follow
// ---------------------------------------------------------------------------
async function listFollowing(req, res, next) {
  try {
    const userId = req.user.id;
    const rows = await db('user_follows')
      .leftJoin('users', 'user_follows.followed_id', 'users.id')
      .where('user_follows.follower_id', userId)
      .select('users.id', 'users.name', 'users.user_type', 'users.photo_url', 'users.avatar_hue', 'users.is_verified');
    ok(res, rows);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /feed/notifications — List feed notifications
// ---------------------------------------------------------------------------
async function listFeedNotifications(req, res, next) {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 30 } = req.query;
    const total = await db('feed_notifications').where({ recipient_id: userId }).count('* as c').first().then(r => +r.c);
    const rows = await db('feed_notifications')
      .leftJoin('users', 'feed_notifications.actor_id', 'users.id')
      .leftJoin('candidates', function () {
        this.on('users.id', '=', 'candidates.user_id').andOn('users.user_type', '=', db.raw("'candidate'"));
      })
      .leftJoin('businesses', function () {
        this.on('users.id', '=', 'businesses.user_id').andOn('users.user_type', '=', db.raw("'business'"));
      })
      .where('feed_notifications.recipient_id', userId)
      .select(
        'feed_notifications.id', 'feed_notifications.action_type',
        'feed_notifications.post_id', 'feed_notifications.preview',
        'feed_notifications.is_read', 'feed_notifications.created_at',
        'users.name as actor_name', 'users.user_type as actor_type',
        'users.photo_url as actor_photo_url', 'users.avatar_hue as actor_avatar_hue',
        'users.is_verified as actor_verified',
        db.raw("COALESCE(candidates.initials, businesses.initials, LEFT(users.name, 2)) as actor_initials"),
      )
      .orderBy('feed_notifications.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /feed/notifications/count — Unread count
// ---------------------------------------------------------------------------
async function unreadNotifCount(req, res, next) {
  try {
    const c = await db('feed_notifications').where({ recipient_id: req.user.id, is_read: false }).count('* as c').first();
    ok(res, { count: +(c?.c || 0) });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /feed/notifications/:id/read — Mark one as read
// ---------------------------------------------------------------------------
async function markNotifRead(req, res, next) {
  try {
    await db('feed_notifications').where({ id: req.params.id, recipient_id: req.user.id }).update({ is_read: true });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /feed/notifications/read-all — Mark all as read
// ---------------------------------------------------------------------------
async function markAllNotifsRead(req, res, next) {
  try {
    await db('feed_notifications').where({ recipient_id: req.user.id, is_read: false }).update({ is_read: true });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/:id/save — Save/bookmark a post
// ---------------------------------------------------------------------------
async function savePost(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const existing = await db('post_saves').where({ post_id: postId, user_id: userId }).first();
    if (!existing) {
      await db('post_saves').insert({ post_id: postId, user_id: userId });
      await db('feed_posts').where({ id: postId }).increment('save_count', 1);
    }
    ok(res, { saved: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /feed/:id/save — Unsave/unbookmark a post
// ---------------------------------------------------------------------------
async function unsavePost(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const deleted = await db('post_saves').where({ post_id: postId, user_id: userId }).del();
    if (deleted > 0) {
      await db('feed_posts').where({ id: postId }).decrement('save_count', 1);
    }
    ok(res, { saved: false });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /feed/:id/view — Record a view (deduplicated per user)
// ---------------------------------------------------------------------------
async function recordView(req, res, next) {
  try {
    const postId = req.params.id;
    const userId = req.user.id;
    const existing = await db('post_views').where({ post_id: postId, user_id: userId }).first();
    if (!existing) {
      await db('post_views').insert({ post_id: postId, user_id: userId });
      await db('feed_posts').where({ id: postId }).increment('view_count', 1);
    }
    ok(res, { viewed: true });
  } catch (err) { next(err); }
}

module.exports = { listPosts, createPost, toggleLike, listComments, addComment, deletePost, seedFeed, followUser, unfollowUser, listFollowing, listFeedNotifications, unreadNotifCount, markNotifRead, markAllNotifsRead, savePost, unsavePost, recordView };
