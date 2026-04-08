import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const Color _orange = Color(0xFFF97316);

class ServicePostDetailView extends StatefulWidget {
  final String postId;
  const ServicePostDetailView({super.key, required this.postId});

  @override
  State<ServicePostDetailView> createState() => _ServicePostDetailViewState();
}

class _ServicePostDetailViewState extends State<ServicePostDetailView> {
  bool _isSaved = false;

  Map<String, dynamic> get _post {
    final match = MockData.serviceFeedPosts.cast<Map<String, dynamic>>().where((p) => p['id'] == widget.postId);
    if (match.isNotEmpty) return match.first;
    return MockData.serviceFeedPosts.first as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> get _relatedPosts {
    final post = _post;
    final companyId = post['companyId'] as String;
    final allPosts = MockData.serviceFeedPosts.cast<Map<String, dynamic>>().toList();
    // Posts from same company, excluding current
    var related = allPosts.where((p) => p['companyId'] == companyId && p['id'] != widget.postId).toList();
    // If less than 2, fill with other posts
    if (related.length < 2) {
      final other = allPosts.where((p) => p['id'] != widget.postId && !related.any((r) => r['id'] == p['id'])).toList();
      related.addAll(other.take(2 - related.length));
    }
    return related.take(2).toList();
  }

  Color _colorFromName(String name) {
    final hash = name.hashCode.abs();
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.5, 0.45).toColor();
  }

  Color _bgColorFromName(String name) {
    final hash = name.hashCode.abs();
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.25, 0.92).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final company = post['company'] as String;
    final companyInitials = post['companyInitials'] as String;
    final companyId = post['companyId'] as String;
    final category = post['category'] as String;
    final text = post['text'] as String;
    final time = post['time'] as String;
    final mediaType = post['mediaType'] as String;

    // Media colors
    Color mediaStartColor;
    Color mediaEndColor;
    Widget? mediaOverlay;
    switch (mediaType) {
      case 'video':
        mediaStartColor = Colors.purple.shade300;
        mediaEndColor = Colors.purple.shade600;
        mediaOverlay = const Icon(Icons.play_circle_fill, size: 56, color: Colors.white);
      case 'promo':
        mediaStartColor = _orange;
        mediaEndColor = _orange.withValues(alpha: 0.7);
        mediaOverlay = Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const Text('OFFER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _orange)),
        );
      default:
        mediaStartColor = Colors.blue.shade300;
        mediaEndColor = Colors.blue.shade600;
        mediaOverlay = null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(company),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: _bgColorFromName(company), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(companyInitials, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _colorFromName(company))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Text(time, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Large media placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [mediaStartColor, mediaEndColor],
                ),
              ),
              alignment: Alignment.center,
              child: mediaOverlay,
            ),

            const SizedBox(height: 16),

            // Full text content
            Text(text, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.5)),

            const SizedBox(height: 12),

            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _orange)),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/services/company/$companyId'),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.center,
                      child: const Text('View Company Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _isSaved = !_isSaved),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      _isSaved ? Icons.favorite : Icons.favorite_border,
                      size: 22,
                      color: _isSaved ? Colors.red : AppColors.tertiary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Related Posts
            const Text('Related Posts', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 12),

            ..._relatedPosts.map((rp) => _relatedPostCard(rp)),
          ],
        ),
      ),
    );
  }

  Widget _relatedPostCard(Map<String, dynamic> p) {
    final company = p['company'] as String;
    final companyInitials = p['companyInitials'] as String;
    final text = p['text'] as String;
    final time = p['time'] as String;
    final postId = p['id'] as String;

    return GestureDetector(
      onTap: () => context.push('/services/posts/$postId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _bgColorFromName(company), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(companyInitials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _colorFromName(company))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  const SizedBox(height: 2),
                  Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
