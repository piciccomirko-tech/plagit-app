import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const Color _orange = Color(0xFFF97316);

class ServiceDiscoverView extends StatefulWidget {
  const ServiceDiscoverView({super.key});

  @override
  State<ServiceDiscoverView> createState() => _ServiceDiscoverViewState();
}

class _ServiceDiscoverViewState extends State<ServiceDiscoverView> {
  String _searchText = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Newest';
  final Set<String> _savedIds = {...MockData.serviceSavedCompanyIds};

  static const _sortOptions = ['Newest', 'Featured', 'Nearby', 'A-Z'];

  List<Map<String, dynamic>> get _filtered {
    var list = MockData.serviceCompanies.cast<Map<String, dynamic>>().toList();
    if (_selectedCategory != 'All') {
      list = list.where((c) => c['category'] == _selectedCategory).toList();
    }
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      list = list.where((c) =>
          (c['name'] as String).toLowerCase().contains(q) ||
          (c['category'] as String).toLowerCase().contains(q) ||
          (c['subcategory'] as String).toLowerCase().contains(q)).toList();
    }
    switch (_sortBy) {
      case 'Featured':
        list.sort((a, b) => (b['featured'] == true ? 1 : 0).compareTo(a['featured'] == true ? 1 : 0));
      case 'Nearby':
        list.sort((a, b) => _parseDistance(a['distance']).compareTo(_parseDistance(b['distance'])));
      case 'A-Z':
        list.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      default:
        break;
    }
    return list;
  }

  double _parseDistance(String d) {
    return double.tryParse(d.replaceAll(' mi', '')) ?? 99;
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
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover Companies'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: AppColors.tertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _searchText = v),
                            style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
                            decoration: const InputDecoration(
                              hintText: 'Search companies...',
                              hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => context.push('/services/search'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.filter_list, size: 20, color: AppColors.charcoal),
                  ),
                ),
              ],
            ),
          ),

          // Category chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip('All'),
                ...MockData.serviceCategories.map((cat) => _categoryChip(cat['name'] as String)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _sortOptions.map((opt) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _sortBy = opt),
                  child: Column(
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _sortBy == opt ? FontWeight.w600 : FontWeight.w400,
                          color: _sortBy == opt ? _orange : AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 30,
                        color: _sortBy == opt ? _orange : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filtered.length} companies found',
                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Company list
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No companies found', style: TextStyle(color: AppColors.secondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _companyCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String name) {
    final isSelected = _selectedCategory == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _orange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
          ),
        ),
      ),
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
    final isSaved = _savedIds.contains(id);

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
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _bgColorFromName(name),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _colorFromName(name)),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
            // Right icons
            Column(
              children: [
                if (verified)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.verified, size: 18, color: AppColors.teal),
                  ),
                if (featured)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.star, size: 18, color: AppColors.gold),
                  ),
                GestureDetector(
                  onTap: () => setState(() {
                    if (isSaved) {
                      _savedIds.remove(id);
                    } else {
                      _savedIds.add(id);
                    }
                  }),
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isSaved ? Colors.red : AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
