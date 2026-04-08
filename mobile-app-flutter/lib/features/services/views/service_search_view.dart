import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const Color _orange = Color(0xFFF97316);

class ServiceSearchView extends StatefulWidget {
  const ServiceSearchView({super.key});

  @override
  State<ServiceSearchView> createState() => _ServiceSearchViewState();
}

class _ServiceSearchViewState extends State<ServiceSearchView> {
  final TextEditingController _controller = TextEditingController();
  String _searchText = '';

  static const _recentSearches = ['Catering London', 'DJ services', 'Cleaning'];

  static const _categoryIcons = {
    'Food & Beverage Suppliers': Icons.restaurant,
    'Event Services': Icons.celebration,
    'Decor & Design': Icons.palette,
    'Entertainment': Icons.music_note,
    'Equipment & Operations': Icons.build,
    'Cleaning & Maintenance': Icons.cleaning_services,
  };

  List<Map<String, dynamic>> get _results {
    if (_searchText.isEmpty) return [];
    final q = _searchText.toLowerCase();
    return MockData.serviceCompanies.cast<Map<String, dynamic>>().where((c) =>
        (c['name'] as String).toLowerCase().contains(q) ||
        (c['category'] as String).toLowerCase().contains(q) ||
        (c['subcategory'] as String).toLowerCase().contains(q)).toList();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() => _searchText = v),
          style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
          decoration: const InputDecoration(
            hintText: 'Search companies, services...',
            hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 15),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20, color: AppColors.tertiary),
              onPressed: () {
                _controller.clear();
                setState(() => _searchText = '');
              },
            ),
        ],
      ),
      body: _searchText.isEmpty ? _emptySearchBody() : _resultsBody(),
    );
  }

  Widget _emptySearchBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          const Text('Recent Searches', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 12),
          ..._recentSearches.map((s) => GestureDetector(
            onTap: () {
              _controller.text = s;
              setState(() => _searchText = s);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 18, color: AppColors.tertiary),
                  const SizedBox(width: 10),
                  Text(s, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                ],
              ),
            ),
          )),

          const SizedBox(height: 24),

          // Categories grid
          const Text('Browse Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: MockData.serviceCategories.map((cat) {
              final name = cat['name'] as String;
              final icon = _categoryIcons[name] ?? Icons.category;
              return GestureDetector(
                onTap: () {
                  _controller.text = name;
                  setState(() => _searchText = name);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: _orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.charcoal),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resultsBody() {
    final results = _results;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.tertiary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text('No results found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: 4),
            const Text('Try a different search term', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (_, i) => _companyCard(results[i]),
    );
  }

  Widget _companyCard(Map<String, dynamic> c) {
    final name = c['name'] as String;
    final initials = c['initials'] as String;
    final category = c['category'] as String;
    final location = c['location'] as String;
    final distance = c['distance'] as String;
    final description = c['description'] as String;
    final verified = c['verified'] == true;
    final featured = c['featured'] == true;
    final id = c['id'] as String;

    return GestureDetector(
      onTap: () => context.push('/services/company/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: _bgColorFromName(name), shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initials, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _colorFromName(name))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: _orange)),
                  ),
                  const SizedBox(height: 4),
                  Text('$location  \u00b7  $distance', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                  const SizedBox(height: 2),
                  Text(description, style: const TextStyle(fontSize: 12, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                if (verified)
                  const Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.verified, size: 18, color: AppColors.teal)),
                if (featured)
                  const Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.star, size: 18, color: AppColors.gold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
