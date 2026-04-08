import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const Color _orange = Color(0xFFF97316);

class ServiceFeedView extends StatefulWidget {
  const ServiceFeedView({super.key});

  @override
  State<ServiceFeedView> createState() => _ServiceFeedViewState();
}

class _ServiceFeedViewState extends State<ServiceFeedView> {
  String _filter = 'All';
  final Set<String> _savedPostIds = {};

  static const _filters = ['All', 'Following', 'Photos', 'Videos', 'Promotions'];

  List<Map<String, dynamic>> get _filteredPosts {
    final posts = MockData.serviceFeedPosts.cast<Map<String, dynamic>>().toList();
    switch (_filter) {
      case 'Photos':
        return posts.where((p) => p['mediaType'] == 'photo').toList();
      case 'Videos':
        return posts.where((p) => p['mediaType'] == 'video').toList();
      case 'Promotions':
        return posts.where((p) => p['isPromo'] == true).toList();
      case 'Following':
        // Mock: show first 3 as "following"
        return posts.take(3).toList();
      default:
        return posts;
    }
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
    final posts = _filteredPosts;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Latest Updates'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: _filters.map((f) {
                final isSelected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _orange : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Feed list
          Expanded(
            child: posts.isEmpty
                ? const Center(child: Text('No posts found', style: TextStyle(color: AppColors.secondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (_, i) => _postCard(posts[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> p) {
    final company = p['company'] as String;
    final companyInitials = p['companyInitials'] as String;
    final category = p['category'] as String;
    final text = p['text'] as String;
    final time = p['time'] as String;
    final mediaType = p['mediaType'] as String;
    final postId = p['id'] as String;
    final companyId = p['companyId'] as String;
    final isSaved = _savedPostIds.contains(postId);

    // Media colors
    Color mediaStartColor;
    Color mediaEndColor;
    Widget? mediaOverlay;
    switch (mediaType) {
      case 'video':
        mediaStartColor = Colors.purple.shade300;
        mediaEndColor = Colors.purple.shade600;
        mediaOverlay = const Icon(Icons.play_circle_fill, size: 44, color: Colors.white);
      case 'promo':
        mediaStartColor = _orange;
        mediaEndColor = _orange.withValues(alpha: 0.7);
        mediaOverlay = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: const Text('OFFER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _orange)),
        );
      default:
        mediaStartColor = Colors.blue.shade300;
        mediaEndColor = Colors.blue.shade600;
        mediaOverlay = null;
    }

    return GestureDetector(
      onTap: () => context.push('/services/posts/$postId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: _bgColorFromName(company), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(companyInitials, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _colorFromName(company))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: _orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: _orange)),
                          ),
                          const SizedBox(width: 6),
                          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Text content
            Text(text, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4)),

            const SizedBox(height: 10),

            // Media placeholder
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [mediaStartColor, mediaEndColor],
                ),
              ),
              alignment: Alignment.center,
              child: mediaOverlay,
            ),

            const SizedBox(height: 10),

            // Footer
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    if (isSaved) {
                      _savedPostIds.remove(postId);
                    } else {
                      _savedPostIds.add(postId);
                    }
                  }),
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isSaved ? Colors.red : AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/services/company/$companyId'),
                  child: const Text('View Company', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
