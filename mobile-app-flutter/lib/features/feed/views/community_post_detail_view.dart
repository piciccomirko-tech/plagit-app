import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/demo_content_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/time_helpers.dart';
import 'package:plagit/core/widgets/post_insights_sheet.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/community_post.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/community_provider.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _border = Color(0xFFE6E8ED);
const _urgent = Color(0xFFFF3B30);

/// Full-screen post detail with comment thread + composer.
///
/// Reads & writes through the shared `CommunityProvider` so any like /
/// comment / save action is instantly reflected in the feed list.
class CommunityPostDetailView extends StatefulWidget {
  final String postId;
  final bool focusComment;
  const CommunityPostDetailView({
    super.key,
    required this.postId,
    this.focusComment = false,
  });

  @override
  State<CommunityPostDetailView> createState() => _CommunityPostDetailViewState();
}

class _CommunityPostDetailViewState extends State<CommunityPostDetailView> {
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.focusComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _commentFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final post = provider.postById(widget.postId);

    if (post == null) {
      return Scaffold(
        backgroundColor: _bgMain,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle, size: 40, color: _tertiary),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).postNotFound, style: TextStyle(fontSize: 15, color: _charcoal)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Text(AppLocalizations.of(context).goBack, style: TextStyle(fontSize: 14, color: _tealMain, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final comments = provider.commentsFor(post.id);

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const BackChevron(size: 28, color: _charcoal),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).postDetailTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _charcoal,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: 'https://plagit.app/post/${post.id}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).linkCopied), duration: Duration(seconds: 1)),
                      );
                    },
                    child: const Icon(CupertinoIcons.share, size: 20, color: _charcoal),
                  ),
                ],
              ),
            ),

            // ── Scrollable content ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  _buildPostCard(provider, post),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).commentsTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _charcoal, letterSpacing: -0.2),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _tealLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${comments.length}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _tealMain),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (comments.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
                      ),
                      child: const Center(
                        child: Text(
                          'Be the first to comment.',
                          style: TextStyle(fontSize: 13, color: _secondary),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: comments.map((c) => _CommentTile(comment: c)).toList(),
                    ),
                ],
              ),
            ),

            // ── Composer ──
            _CommentComposer(
              controller: _commentCtrl,
              focusNode: _commentFocus,
              onSend: (text) {
                provider.addComment(post.id, text);
                _commentCtrl.clear();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(CommunityProvider provider, CommunityPost post) {
    final isBusiness = post.authorKind == AuthorKind.business;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                ProfilePhoto(
                  photoUrl: post.authorPhotoUrl,
                  initials: post.authorInitials,
                  size: 52,
                  square: isBusiness,
                  verified: post.authorVerified,
                  hueSeed: post.authorName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _charcoal,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          if (post.authorVerified) ...[
                            const SizedBox(width: 5),
                            const Icon(CupertinoIcons.checkmark_seal_fill, size: 14, color: _tealMain),
                          ],
                          if (isBusiness) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _tealLight,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Text(
                                'Business',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _tealMain),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${localizedJobRole(context, post.authorRole)}${post.authorLocation != null ? ' · ${localizedCity(context, post.authorLocation)}' : ''} · ${shortTimeAgo(context, post.timeAgo)}',
                        style: const TextStyle(fontSize: 12, color: _tertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body — full text, no truncation
          if (post.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                localizeDemoPostBody(context, post.body),
                style: const TextStyle(fontSize: 15, color: _charcoal, height: 1.45, letterSpacing: -0.1),
              ),
            ),

          // Media
          if (post.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image(
                    image: post.images.first.startsWith('http')
                        ? NetworkImage(post.images.first) as ImageProvider
                        : AssetImage(post.images.first),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFEFEFF4),
                      child: const Center(child: Icon(CupertinoIcons.photo, size: 32, color: _tertiary)),
                    ),
                  ),
                ),
              ),
            ),

          // ── Compact meta counts ──
          // Counts live here so the action buttons below only need to show
          // icon + label — no more "$label · $count" overflow at narrow
          // widths. Reads like a proper premium post meta line.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: Row(
              children: [
                _metaStat(
                  AppLocalizations.of(context).likesCount(post.likes),
                ),
                const _MetaDot(),
                _metaStat(
                  AppLocalizations.of(context).commentsCount(post.commentsCount),
                ),
                const _MetaDot(),
                _metaStat(
                  AppLocalizations.of(context).savesCount(post.saves),
                ),
                const Spacer(),
                const Icon(CupertinoIcons.eye, size: 11, color: _tertiary),
                const SizedBox(width: 4),
                Text(
                  '${post.views}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _tertiary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),

          // ── Action row — icon + short label only, never truncates ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFEFEFF4), width: 0.5)),
            ),
            child: Row(
              children: [
                _BigActionBtn(
                  icon: post.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                  label: AppLocalizations.of(context).likeAction,
                  active: post.isLiked,
                  activeColor: _urgent,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.toggleLike(post.id);
                  },
                ),
                const SizedBox(width: 8),
                _BigActionBtn(
                  icon: CupertinoIcons.chat_bubble,
                  label: AppLocalizations.of(context).commentAction,
                  onTap: () => _commentFocus.requestFocus(),
                ),
                const SizedBox(width: 8),
                _BigActionBtn(
                  icon: post.isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                  label: AppLocalizations.of(context).saveActionLabel,
                  active: post.isSaved,
                  activeColor: _tealMain,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.toggleSave(post.id);
                  },
                ),
              ],
            ),
          ),

          // ── View Insights — only shown to the post's author ──
          // Tapping the views counter / "View Insights" pill opens the
          // shared `PostInsightsSheet` with the right premium gating.
          if (post.authorId == provider.viewerId)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: GestureDetector(
                onTap: () => _openInsights(context, provider, post),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _tealMain.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _tealMain.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.chart_bar_alt_fill, size: 14, color: _tealMain),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'View Insights — ${post.views} views · ${post.saves} saves',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _tealMain,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const ForwardChevron(size: 28, color: _tealMain),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openInsights(
    BuildContext context,
    CommunityProvider provider,
    CommunityPost post,
  ) {
    HapticFeedback.lightImpact();
    final candidateAuth = context.read<CandidateAuthProvider>();
    final isPremium = candidateAuth.profile?.isPremium ?? false;
    PostInsightsSheet.show(
      context,
      insights: provider.insightsFor(post.id),
      post: post,
      isPremium: isPremium,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// COMMENT TILE
// ═══════════════════════════════════════════════════════════════

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isBusiness = comment.authorKind == AuthorKind.business;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfilePhoto(
            photoUrl: comment.authorPhotoUrl,
            initials: comment.authorInitials,
            size: 38,
            square: isBusiness,
            verified: comment.authorVerified,
            hueSeed: comment.authorName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _charcoal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (comment.authorVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.checkmark_seal_fill, size: 12, color: _tealMain),
                    ],
                    const SizedBox(width: 6),
                    Text(
                      shortTimeAgo(context, comment.timeAgo),
                      style: const TextStyle(fontSize: 11, color: _tertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  localizeDemoComment(context, comment.body),
                  style: const TextStyle(fontSize: 13.5, color: _charcoal, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// COMPOSER
// ═══════════════════════════════════════════════════════════════

class _CommentComposer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSend;
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final ok = widget.controller.text.trim().isNotEmpty;
    if (ok != _canSend) setState(() => _canSend = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        border: const Border(top: BorderSide(color: _border, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.of(context).viewInsets.bottom),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 110),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 14, color: _charcoal, height: 1.35),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).addCommentHint,
                      hintStyle: const TextStyle(fontSize: 14, color: _tertiary),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _canSend ? () => widget.onSend(widget.controller.text) : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _canSend ? _tealMain : _surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_up,
                    size: 18,
                    color: _canSend ? Colors.white : _tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _BigActionBtn({
    required this.icon,
    required this.label,
    this.active = false,
    this.activeColor = _tealMain,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : _secondary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: 0.10) : _surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// META STATS (compact counters above the action row)
// ═══════════════════════════════════════════════════════════════

Widget _metaStat(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: _secondary,
      letterSpacing: -0.1,
    ),
  );
}

class _MetaDot extends StatelessWidget {
  const _MetaDot();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '·',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _tertiary,
          ),
        ),
      );
}
