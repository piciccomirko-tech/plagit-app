/**
 * Seed realistic social feed posts for demo.
 * Run: node db/seed_feed.js
 */
require('dotenv').config();
const db = require('../src/config/db');

const USERS = {
  elena:  'ea45e17e-7312-47bc-a10e-8241da12c87c',
  james:  '6e38d991-0b4d-41d2-9f62-f2bf13a07210',
  sofia:  '09c6a141-c21b-4016-9041-b1d0aea7884a',
  marco:  '064ca8cd-fed5-466d-bf67-23a60ba7f43a',
  anna:   'c6e9da17-f49f-4d97-9dc5-fc955c991ab0',
  tom:    '97b09256-e199-4aa9-b8cf-050dac81cc60',
  priya:  '0d713776-888d-45e4-bcbf-dc1bceae8785',
  david:  '1f4dd464-c0ed-468e-b19b-136267f7aae7',
  nobu:   '032b64a6-c8f8-4662-8107-a9ae1d1b1f1b',
  ritz:   '317d542e-f4f6-421b-8798-5f1b9d1c0af3',
  dishoom:'7e463da4-a8a4-4061-9ca3-721cf6535a36',
  sky:    'f3bdd767-bedf-4db6-b7ac-f3552d5990dd',
  fabric: 'de943ab9-0984-4351-a080-ff0cf024fa47',
  four:   'a7d955d2-eadb-42bf-a948-1eba6765c72b',
};

function hoursAgo(h) {
  return new Date(Date.now() - h * 3600000).toISOString();
}

const POSTS = [
  { user_id: USERS.elena, body: "Just finished a 14-hour double shift and still managed to plate 200+ covers without sending back a single dish. That's what 8 years in fine dining does to you. 🔥\n\nIf you're looking for a Head Chef who can handle pressure, my DMs are open.", tag: 'open_to_work', role_category: 'chef', location: 'London, UK', latitude: 51.5074, longitude: -0.1278, like_count: 47, comment_count: 8, created_at: hoursAgo(2) },
  { user_id: USERS.nobu, body: "We're expanding our London team! Looking for passionate sushi chefs and experienced waitstaff who want to be part of something special.\n\nCompetitive salary, world-class training, and the chance to work with Nobu Matsuhisa's recipes. Apply through Plagit or DM us.", tag: 'hiring', role_category: 'chef', location: 'Mayfair, London', latitude: 51.5099, longitude: -0.1496, like_count: 82, comment_count: 15, created_at: hoursAgo(3) },
  { user_id: USERS.james, body: "Quick tip for bartenders doing interviews: always ask about the cocktail menu and suggest one improvement. Shows initiative and knowledge.\n\nLanded my current role at Sky Lounge exactly like this. 🍸", role_category: 'bartender', location: 'London, UK', latitude: 51.5155, longitude: -0.0834, like_count: 93, comment_count: 12, created_at: hoursAgo(5) },
  { user_id: USERS.ritz, body: "Proud to announce that three of our team members have been promoted this quarter. At The Ritz, we believe in growing talent from within.\n\nCurrently looking for a Front of House Manager to join our legendary team. Must have 5+ years luxury hospitality experience.", tag: 'hiring', role_category: 'manager', location: 'Piccadilly, London', latitude: 51.5071, longitude: -0.1413, like_count: 64, comment_count: 6, created_at: hoursAgo(7) },
  { user_id: USERS.sofia, body: "Moved to London from Paris 6 months ago. Best decision I ever made. The hospitality scene here is incredible — so many opportunities if you're willing to work hard.\n\nCurrently working as a sommelier at a Michelin-starred restaurant and loving every minute. Happy to connect with fellow hospitality workers!", tag: 'open_to_work', role_category: 'waiter', location: 'Soho, London', latitude: 51.5136, longitude: -0.1365, like_count: 56, comment_count: 9, created_at: hoursAgo(10) },
  { user_id: USERS.dishoom, body: "Our Soho kitchen team just won 'Best Casual Dining Kitchen' at the London Restaurant Awards! So proud of every single person who makes our naan fresh 900 times a day.\n\nWe're hiring kitchen porters and line cooks. No ego, just great food and great people.", tag: 'hiring', role_category: 'kitchen_porter', location: 'Soho, London', latitude: 51.5133, longitude: -0.1315, like_count: 121, comment_count: 18, created_at: hoursAgo(12) },
  { user_id: USERS.marco, body: "After 3 years of working doubles, I finally got my first management position. Started as a runner, worked my way up to floor manager.\n\nNever let anyone tell you hospitality isn't a real career. The skills you learn — leadership, multitasking, grace under pressure — are invaluable.", role_category: 'manager', location: 'Shoreditch, London', latitude: 51.5242, longitude: -0.0775, like_count: 178, comment_count: 24, created_at: hoursAgo(15) },
  { user_id: USERS.anna, body: "Available for shifts this weekend! I'm a trained barista and waitress with 4 years experience. Based in East London but happy to travel.\n\nReliable, fast learner, great with customers. References available.", tag: 'available_for_shifts', role_category: 'waiter', location: 'East London', latitude: 51.5321, longitude: -0.0515, like_count: 23, comment_count: 3, created_at: hoursAgo(18) },
  { user_id: USERS.sky, body: "Sunset service at 40 floors up. There's nothing quite like it. 🌅\n\nWe're looking for experienced bartenders who can craft cocktails with a view. Must be comfortable with high-volume service and VIP clientele.", tag: 'looking_for_staff', role_category: 'bartender', location: 'Tower Bridge, London', latitude: 51.5055, longitude: -0.0754, like_count: 95, comment_count: 11, created_at: hoursAgo(20) },
  { user_id: USERS.tom, body: "Does anyone else feel like the industry is finally starting to take work-life balance seriously? More restaurants offering 4-day weeks, proper breaks, mental health support.\n\nIt's about time. Burnout is real in this industry.", role_category: 'chef', location: 'Camden, London', latitude: 51.5390, longitude: -0.1426, like_count: 234, comment_count: 31, created_at: hoursAgo(24) },
  { user_id: USERS.priya, body: "Just completed my Level 3 Food Safety certification! 📜\n\nInvesting in yourself is the best thing you can do in this industry. Next up: Wine & Spirit Education Trust Level 2.", role_category: 'waiter', location: 'Canary Wharf, London', latitude: 51.5054, longitude: -0.0235, like_count: 67, comment_count: 5, created_at: hoursAgo(30) },
  { user_id: USERS.four, body: "At Four Seasons, we don't just hire staff — we build careers. Our graduate programme has a 94% retention rate.\n\nNow accepting applications for our 2026 intake across all departments: kitchen, front of house, reception, and concierge.", tag: 'hiring', role_category: 'reception', location: 'Park Lane, London', latitude: 51.5040, longitude: -0.1505, like_count: 88, comment_count: 7, created_at: hoursAgo(36) },
  { user_id: USERS.david, body: "Looking for a Head Chef position in Central London. 10 years experience across fine dining, casual, and hotel restaurants. Specialise in modern European with Asian influences.\n\nHappy to do a trial shift. Let's connect!", tag: 'open_to_work', role_category: 'chef', location: 'Central London', latitude: 51.5099, longitude: -0.1337, like_count: 41, comment_count: 6, created_at: hoursAgo(42) },
  { user_id: USERS.fabric, body: "Our events team is growing! We need experienced bartenders and floor staff for the summer season. Fast-paced, exciting environment.\n\nFlexible shifts available — perfect if you're studying or have another job.", tag: 'looking_for_staff', role_category: 'bartender', location: 'Farringdon, London', latitude: 51.5200, longitude: -0.1052, like_count: 53, comment_count: 4, created_at: hoursAgo(48) },
  { user_id: USERS.elena, body: "Pro tip for anyone doing a kitchen trial: arrive 15 minutes early, bring your own knives (sharpened), and always say 'yes chef'. It's not about ego, it's about respect for the brigade system.\n\nWhat's your best interview/trial tip?", role_category: 'chef', location: 'London, UK', latitude: 51.5074, longitude: -0.1278, like_count: 112, comment_count: 19, created_at: hoursAgo(52) },
];

const COMMENTS = [
  // Elena's first post
  { postIdx: 0, user_id: USERS.james, body: "14 hours and still going strong 💪 That's proper chef energy." },
  { postIdx: 0, user_id: USERS.nobu, body: "We'd love to chat. Send your CV through Plagit!" },
  { postIdx: 0, user_id: USERS.marco, body: "This is what separates good chefs from great ones. Respect." },
  // Nobu hiring post
  { postIdx: 1, user_id: USERS.elena, body: "Nobu is a dream workplace. Applied!" },
  { postIdx: 1, user_id: USERS.sofia, body: "Do you have sommelier positions as well?" },
  { postIdx: 1, user_id: USERS.tom, body: "Worked with your team before. Amazing kitchen culture." },
  // James bartender tip
  { postIdx: 2, user_id: USERS.anna, body: "This is such great advice. Doing this in my next interview!" },
  { postIdx: 2, user_id: USERS.priya, body: "Can confirm — this works. Asked about the wine list at mine and got the job same day." },
  // Marco management post
  { postIdx: 6, user_id: USERS.elena, body: "So proud of you Marco! This is what hard work looks like." },
  { postIdx: 6, user_id: USERS.ritz, body: "Love to see this. Hospitality careers are absolutely real and rewarding." },
  { postIdx: 6, user_id: USERS.david, body: "Started as a KP myself. Now leading a team of 12. The journey is worth it." },
  // Tom work-life balance post
  { postIdx: 9, user_id: USERS.sofia, body: "Finally! I left my last place because of 60-hour weeks with no overtime pay." },
  { postIdx: 9, user_id: USERS.dishoom, body: "We've been doing 4-day weeks for our kitchen team since 2024. Retention went up 40%." },
  { postIdx: 9, user_id: USERS.anna, body: "Mental health support should be standard. I burned out twice before I learned to set boundaries." },
  { postIdx: 9, user_id: USERS.four, body: "At Four Seasons we provide 24/7 counselling access for all staff. It makes a real difference." },
  // Elena's tip post
  { postIdx: 14, user_id: USERS.marco, body: "Always taste everything before you send it. Obvious but so many people skip it." },
  { postIdx: 14, user_id: USERS.james, body: "For bartenders: memorise 3 classic cocktail recipes that aren't on the menu. Shows depth." },
  { postIdx: 14, user_id: USERS.david, body: "Ask questions. A chef who's curious will always out-perform one who just follows orders." },
];

(async () => {
  try {
    console.log('Clearing old feed data...');
    await db('post_comments').del();
    await db('post_likes').del();
    await db('feed_posts').del();

    console.log(`Inserting ${POSTS.length} feed posts...`);
    const inserted = [];
    for (const post of POSTS) {
      const [row] = await db('feed_posts').insert(post).returning('*');
      inserted.push(row);
    }

    console.log(`Inserting ${COMMENTS.length} comments...`);
    for (const comment of COMMENTS) {
      const post = inserted[comment.postIdx];
      await db('post_comments').insert({
        post_id: post.id, user_id: comment.user_id, body: comment.body,
      });
    }

    // Add some likes
    console.log('Adding likes...');
    const allUserIds = Object.values(USERS);
    for (const post of inserted) {
      // Random subset of users liked each post
      const likers = allUserIds.filter(() => Math.random() < 0.4);
      for (const uid of likers) {
        try {
          await db('post_likes').insert({ post_id: post.id, user_id: uid });
        } catch (e) { /* unique constraint — skip */ }
      }
    }

    console.log('Done! Feed seeded successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
})();
