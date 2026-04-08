import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/widgets/profile_avatar.dart';

/// Saved posts section with category filters and search.
/// Mirrors SavedPostsView.swift.
class SavedPostsView extends StatefulWidget {
  const SavedPostsView({super.key});

  @override
  State<SavedPostsView> createState() => _SavedPostsViewState();
}

enum _SavedCategory {
  recipes('Recipes', Icons.restaurant),
  tips('Tips', Icons.lightbulb_outline),
  jobs('Jobs', Icons.work_outline),
  events('Events', Icons.event),
  other('Other', Icons.bookmark_border);

  final String label;
  final IconData icon;
  const _SavedCategory(this.label, this.icon);
}

class _MockSavedPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final double authorHue;
  final String? authorLocation;
  final bool authorVerified;
  final String body;
  final int likeCount;
  final int commentCount;
  final _SavedCategory category;

  const _MockSavedPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    this.authorHue = 0.5,
    this.authorLocation,
    this.authorVerified = false,
    required this.body,
    this.likeCount = 0,
    this.commentCount = 0,
    this.category = _SavedCategory.other,
  });
}

class _SavedPostsViewState extends State<SavedPostsView> {
  String _searchText = '';
  _SavedCategory? _selectedCategory;

  final List<_MockSavedPost> _posts = const [
    _MockSavedPost(
      id: '1', authorName: 'Marco Rossi', authorInitials: 'MR', authorHue: 0.55, authorLocation: 'Milan, Italy',
      authorVerified: true, body: 'Best pasta carbonara technique: use guanciale, not pancetta. The fat renders differently and gives a smoky, rich flavor.', likeCount: 42, commentCount: 8, category: _SavedCategory.recipes,
    ),
    _MockSavedPost(
      id: '2', authorName: 'Sophie Laurent', authorInitials: 'SL', authorHue: 0.3, authorLocation: 'Paris, France',
      body: 'Tip for new bartenders: always chill your glasses before serving cocktails. It makes a huge difference in presentation and taste.', likeCount: 28, commentCount: 5, category: _SavedCategory.tips,
    ),
    _MockSavedPost(
      id: '3', authorName: 'The Grand Hotel', authorInitials: 'GH', authorHue: 0.7, authorLocation: 'London, UK',
      authorVerified: true, body: 'We\'re hiring Head Chef and Sous Chef positions. Competitive salary, excellent benefits. Apply through Plagit!', likeCount: 65, commentCount: 12, category: _SavedCategory.jobs,
    ),
    _MockSavedPost(
      id: '4', authorName: 'Carlos Mendez', authorInitials: 'CM', authorHue: 0.15,
      body: 'Hospitality networking event next week in Barcelona. Great for meeting industry professionals!', likeCount: 18, commentCount: 3, category: _SavedCategory.events,
    ),
  ];

  List<_MockSavedPost> get _filtered {
    var result = _posts.toList();
    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      result = result.where((p) =>
          p.body.toLowerCase().contains(q) ||
          p.authorName.toLowerCase().contains(q) ||
          p.category.label.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  int _countFor(_SavedCategory cat) => _posts.where((p) => p.category == cat).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.tertiary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchText = v),
                    style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                    decoration: const InputDecoration.collapsed(hintText: 'Search saved posts...', hintStyle: TextStyle(color: AppColors.tertiary)),
                  ),
                ),
                if (_searchText.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchText = ''),
                    child: const Icon(Icons.cancel, size: 16, color: AppColors.tertiary),
                  ),
              ],
            ),
          ),
        ),

        // Category chips
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              children: [
                _chipButton('All', null, _posts.length, _selectedCategory == null, () {
                  setState(() => _selectedCategory = null);
                }),
                const SizedBox(width: AppSpacing.sm),
                ..._SavedCategory.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _chipButton(cat.label, cat.icon, _countFor(cat), _selectedCategory == cat, () {
                    setState(() => _selectedCategory = cat);
                  }),
                )),
              ],
            ),
          ),
        ),

        // Content
        if (_posts.isEmpty)
          Expanded(child: _emptyState())
        else if (_filtered.isEmpty)
          Expanded(child: _noResultsState())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _savedPostCard(_filtered[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chipButton(String label, IconData? icon, int count, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isActive ? null : Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: isActive ? Colors.white : AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary)),
            if (count > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Text('$count', style: TextStyle(fontSize: 11, color: isActive ? Colors.white70 : AppColors.tertiary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _savedPostCard(_MockSavedPost post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ProfileAvatar(initials: post.authorInitials, hue: post.authorHue, size: 36, verified: post.authorVerified),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                    if (post.authorLocation != null)
                      Text(post.authorLocation!, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  ],
                ),
              ),
              // Category pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(post.category.icon, size: 10, color: AppColors.teal),
                    const SizedBox(width: 3),
                    Text(post.category.label, style: const TextStyle(fontSize: 11, color: AppColors.teal)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Body
          Text(post.body, style: const TextStyle(fontSize: 15, color: AppColors.charcoal), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.md),

          // Footer
          Row(
            children: [
              const Icon(Icons.bookmark_remove, size: 14, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              const Text('Unsave', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
              const Spacer(),
              if (post.likeCount > 0) ...[
                const Icon(Icons.favorite_border, size: 12, color: AppColors.tertiary),
                const SizedBox(width: 3),
                Text('${post.likeCount}', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                const SizedBox(width: AppSpacing.md),
              ],
              if (post.commentCount > 0) ...[
                const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.tertiary),
                const SizedBox(width: 3),
                Text('${post.commentCount}', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
              child: const Icon(Icons.bookmark_border, size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No saved posts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Tap the bookmark icon on any post to save it for later.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: const Icon(Icons.search, size: 20, color: AppColors.tertiary),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No results found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => setState(() { _selectedCategory = null; _searchText = ''; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: const Text('Clear Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
