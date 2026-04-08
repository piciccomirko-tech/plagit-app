import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';

/// Browse nearby service companies with radius and category filters.
class ServiceNearbyView extends StatefulWidget {
  const ServiceNearbyView({super.key});

  @override
  State<ServiceNearbyView> createState() => _ServiceNearbyViewState();
}

class _ServiceNearbyViewState extends State<ServiceNearbyView> {
  static const _orange = Color(0xFFF97316);

  String _selectedRadius = '5mi';
  String? _selectedCategory;

  static const _radii = ['1mi', '5mi', '10mi', '25mi'];

  List<Map<String, dynamic>> get _categories =>
      MockData.serviceCategories.cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get _companies {
    var list = MockData.londonCompanies;
    if (_selectedCategory != null) {
      list = list
          .where((c) => c['category'] == _selectedCategory)
          .toList()
          .cast<Map<String, dynamic>>();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: AppSpacing.sm),
            _radiusChips(),
            const SizedBox(height: AppSpacing.sm),
            _categoryChips(),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    '${_companies.length} companies within $_selectedRadius',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.secondary)),
              ),
            ),
            Expanded(child: _companyList()),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.chevron_left,
                    size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Nearby Companies',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/services/map'),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.map, size: 22, color: AppColors.charcoal)),
          ),
        ],
      ),
    );
  }

  Widget _radiusChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: _radii
            .map((r) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRadius = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: _selectedRadius == r
                            ? AppColors.teal
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: _selectedRadius == r
                            ? null
                            : Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(r,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _selectedRadius == r
                                  ? Colors.white
                                  : AppColors.secondary)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = null),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color:
                      _selectedCategory == null ? _orange : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: _selectedCategory == null
                      ? null
                      : Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Text('All',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory == null
                            ? Colors.white
                            : AppColors.secondary)),
              ),
            ),
          ),
          ..._categories.map((cat) {
            final name = cat['name'] as String;
            final isSelected = _selectedCategory == name;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => setState(() =>
                    _selectedCategory = isSelected ? null : name),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isSelected ? _orange : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.secondary)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _companyList() {
    final list = _companies;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child:
                  const Icon(Icons.location_off, size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No companies found nearby',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text('Try increasing the radius or changing filters',
                style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: list.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _companyCard(list[i]),
      ),
    );
  }

  Widget _companyCard(Map<String, dynamic> c) {
    final initials = c['initials'] as String;
    final hue = (initials.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.15, 0.95).toColor();
    final textColor = HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();
    final distance = c['distance'] as String? ?? '';

    return GestureDetector(
      onTap: () => context.push('/services/companies/${c['id']}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(AppRadius.md)),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(c['name'] as String,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.charcoal),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (c['verified'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.verified,
                                size: 14, color: AppColors.teal),
                          ],
                          if (c['premium'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.amber,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full)),
                              child: const Text('PRO',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(c['subcategory'] as String,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.teal),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(c['description'] as String,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.secondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text(c['location'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.tertiary)),
                const Spacer(),
                if (distance.isNotEmpty) ...[
                  const Icon(Icons.near_me, size: 12, color: _orange),
                  const SizedBox(width: AppSpacing.xs),
                  Text(distance,
                      style:
                          const TextStyle(fontSize: 11, color: _orange)),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Text(c['category'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.amber)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
