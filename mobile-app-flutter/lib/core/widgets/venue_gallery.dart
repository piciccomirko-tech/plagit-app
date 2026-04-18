import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const _tealMain = Color(0xFF2BB8B0);

/// Premium venue gallery — swipeable carousel + page indicators + counter.
///
/// Used inside business profile pages and candidate-facing business detail
/// pages. Designed to be media-first but elegant.
///
/// - Cover image / first photo fills the card
/// - Horizontal swipe to browse all photos
/// - Page dots indicator
/// - Photo counter pill
/// - Optional video play button overlay if [videoUrl] is provided
class VenueGallery extends StatefulWidget {
  final List<String> images;
  final String? videoUrl;
  final double height;
  final BorderRadius? borderRadius;
  final VoidCallback? onTapVideo;
  final VoidCallback? onTapImage;

  const VenueGallery({
    super.key,
    required this.images,
    this.videoUrl,
    this.height = 240,
    this.borderRadius,
    this.onTapVideo,
    this.onTapImage,
  });

  @override
  State<VenueGallery> createState() => _VenueGalleryState();
}

class _VenueGalleryState extends State<VenueGallery> {
  late final PageController _pageCtrl;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(18);
    final hasVideo = widget.videoUrl != null && widget.videoUrl!.isNotEmpty;
    final total = widget.images.length;

    if (total == 0) {
      return _emptyState(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          children: [
            // ── PHOTO CAROUSEL ──
            // Uses BouncingScrollPhysics for smooth iOS-style swipe.
            // No inner GestureDetector — that would steal horizontal drags.
            PageView.builder(
              controller: _pageCtrl,
              itemCount: total,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, i) => _smartImage(widget.images[i], widget.height),
            ),

            // ── BOTTOM GRADIENT (passes touch through to PageView) ──
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: IgnorePointer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── PHOTO COUNTER PILL (passes touch through) ──
            Positioned(
              top: 12, right: 12,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.photo, size: 11, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        '${_currentIndex + 1} / $total',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── VIDEO PLAY BUTTON (only intercepts when present) ──
            if (hasVideo)
              Center(
                child: GestureDetector(
                  onTap: widget.onTapVideo,
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(CupertinoIcons.play_fill, size: 22, color: _tealMain),
                    ),
                  ),
                ),
              ),

            // ── PAGE INDICATOR DOTS (passes touch through) ──
            if (total > 1)
              Positioned(
                left: 0, right: 0, bottom: 14,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: List.generate(total, (i) {
                      final active = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BorderRadius radius) {
    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: widget.height,
        width: double.infinity,
        color: const Color(0xFFF2F2F7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.photo_on_rectangle, size: 24, color: Color(0xFFAEAEB2)),
            ),
            const SizedBox(height: 12),
            const Text(
              'No photos yet',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add venue photos to attract candidates',
              style: TextStyle(fontSize: 12, color: Color(0xFFAEAEB2)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders an image from either a network URL or a local asset path.
/// Uses BoxFit.cover for premium fill behavior and handles errors gracefully.
Widget _smartImage(String src, double height) {
  final isAsset = src.startsWith('assets/');
  final errorWidget = Container(
    color: const Color(0xFFF2F2F7),
    child: const Center(
      child: Icon(CupertinoIcons.photo, size: 32, color: Color(0xFFAEAEB2)),
    ),
  );

  if (isAsset) {
    return Image.asset(
      src,
      fit: BoxFit.cover,
      width: double.infinity,
      height: height,
      errorBuilder: (context, error, stack) => errorWidget,
    );
  }
  return Image.network(
    src,
    fit: BoxFit.cover,
    width: double.infinity,
    height: height,
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return Container(
        color: const Color(0xFFF2F2F7),
        child: const Center(child: CupertinoActivityIndicator()),
      );
    },
    errorBuilder: (context, error, stack) => errorWidget,
  );
}

/// A lighter version for use in list cards — single thumbnail with photo count badge.
class VenueGalleryThumb extends StatelessWidget {
  final List<String> images;
  final double size;

  const VenueGalleryThumb({
    super.key,
    required this.images,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(CupertinoIcons.photo, size: 20, color: Color(0xFFAEAEB2)),
      );
    }

    final first = images.first;
    final isAsset = first.startsWith('assets/');
    final fallback = Container(
      width: size, height: size,
      color: const Color(0xFFF2F2F7),
      child: const Icon(CupertinoIcons.photo, size: 18, color: Color(0xFFAEAEB2)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          isAsset
              ? Image.asset(
                  first,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => fallback,
                )
              : Image.network(
                  first,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => fallback,
                ),
          if (images.length > 1)
            Positioned(
              top: 4, right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${images.length - 1}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
