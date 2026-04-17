import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/community_post.dart';
import 'package:plagit/providers/community_provider.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);

/// Create-post composer used by both Candidate and Business viewers.
///
/// The published post is attributed using `CommunityProvider.viewerKind`,
/// which the parent screen sets when the user logs in. The composer itself
/// is identical for both — the only difference is the badge on the post.
class CommunityCreatePostView extends StatefulWidget {
  const CommunityCreatePostView({super.key});

  @override
  State<CommunityCreatePostView> createState() => _CommunityCreatePostViewState();
}

class _CommunityCreatePostViewState extends State<CommunityCreatePostView> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final List<String> _attachedImages = [];
  PostType _postType = PostType.text;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _canPublish => _ctrl.text.trim().isNotEmpty || _attachedImages.isNotEmpty;

  /// Mock attachment — picks one of a small set of stock images so the user
  /// can see the multi-image / image post types render. The real product
  /// would call `image_picker` here.
  void _attachStockImage() {
    const stock = [
      'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=1200',
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=1200',
      'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=1200',
    ];
    setState(() {
      _attachedImages.add(stock[_attachedImages.length % stock.length]);
      _postType = _attachedImages.length > 1 ? PostType.multiImage : PostType.image;
    });
  }

  void _publish() {
    if (!_canPublish) return;
    final provider = context.read<CommunityProvider>();
    provider.createPost(
      body: _ctrl.text,
      type: _postType,
      images: List.unmodifiable(_attachedImages),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).postPublished), duration: Duration(seconds: 1)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final hue = (provider.viewerName.hashCode % 360).abs().toDouble();
    final isBusiness = provider.viewerKind == AuthorKind.business;

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
                      child: const Icon(CupertinoIcons.xmark, size: 16, color: _charcoal),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).newPostTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _canPublish ? _publish : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _canPublish ? _tealMain : _surface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        AppLocalizations.of(context).publishAction,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _canPublish ? Colors.white : _tertiary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Author identity strip ──
            Container(
              margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
                          HSLColor.fromAHSL(1, (hue + 30) % 360, 0.50, 0.50).toColor(),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        provider.viewerInitials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
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
                                provider.viewerName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _charcoal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isBusiness) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _tealLight,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: const Text(
                                  'Business',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _tealMain,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isBusiness
                              ? AppLocalizations.of(context).postingToCommunityAsBusiness
                              : AppLocalizations.of(context).postingToCommunityAsPro,
                          style: const TextStyle(fontSize: 11, color: _tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Composer ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              maxLines: null,
                              style: const TextStyle(fontSize: 16, color: _charcoal, height: 1.45),
                              decoration: InputDecoration(
                                hintText: isBusiness
                                    ? AppLocalizations.of(context).shareVenueUpdate
                                    : AppLocalizations.of(context).whatsOnYourMind,
                                hintStyle: const TextStyle(fontSize: 16, color: _tertiary),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            if (_attachedImages.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 140,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _attachedImages.length,
                                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                                  itemBuilder: (_, i) {
                                    final src = _attachedImages[i];
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Image.network(
                                            src,
                                            width: 180,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) => Container(
                                              width: 180,
                                              height: 140,
                                              color: const Color(0xFFEFEFF4),
                                              child: const Center(
                                                child: Icon(CupertinoIcons.photo, color: _tertiary),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () => setState(() {
                                              _attachedImages.removeAt(i);
                                              _postType = _attachedImages.isEmpty
                                                  ? PostType.text
                                                  : (_attachedImages.length > 1
                                                      ? PostType.multiImage
                                                      : PostType.image);
                                            }),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.55),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(CupertinoIcons.xmark, size: 12, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── Attachment toolbar ──
                    Container(
                      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          _ToolbarButton(
                            icon: CupertinoIcons.photo,
                            label: AppLocalizations.of(context).attachmentPhoto,
                            onTap: _attachStockImage,
                          ),
                          const SizedBox(width: 8),
                          _ToolbarButton(
                            icon: CupertinoIcons.videocam,
                            label: AppLocalizations.of(context).attachmentVideo,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context).videoAttachmentsComingSoon), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _ToolbarButton(
                            icon: CupertinoIcons.location,
                            label: AppLocalizations.of(context).attachmentLocation,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context).locationTaggingComingSoon), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                          const Spacer(),
                          Text(
                            '${_ctrl.text.length}/500',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ToolbarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _tealLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _tealMain),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _tealMain),
            ),
          ],
        ),
      ),
    );
  }
}
