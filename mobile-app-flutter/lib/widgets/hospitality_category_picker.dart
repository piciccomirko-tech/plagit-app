import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/hospitality_catalog.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// 3-step drill-down picker: Category → Subcategory → Role.
/// Mirrors HospitalityCategoryPicker.swift.
class HospitalityCategoryPicker extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialSubcategoryId;
  final String? initialRoleId;
  final void Function(String categoryId, String subcategoryId, String roleId) onSelected;

  const HospitalityCategoryPicker({
    super.key,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.initialRoleId,
    required this.onSelected,
  });

  @override
  State<HospitalityCategoryPicker> createState() => _HospitalityCategoryPickerState();
}

class _HospitalityCategoryPickerState extends State<HospitalityCategoryPicker> {
  int _step = 1;
  String? _categoryId;
  String? _subcategoryId;
  String _search = '';

  HospitalityCategory? get _selectedCategory =>
      _categoryId != null ? HospitalityCatalog.findCategory(_categoryId!) : null;

  HospitalitySubcategory? get _selectedSubcategory {
    final cat = _selectedCategory;
    if (cat == null || _subcategoryId == null) return null;
    try { return cat.subcategories.firstWhere((s) => s.id == _subcategoryId); } catch (_) { return null; }
  }

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _subcategoryId = widget.initialSubcategoryId;
    if (_categoryId != null && _subcategoryId != null) {
      _step = 3;
    } else if (_categoryId != null) {
      _step = 2;
    }
  }

  void _clear() {
    setState(() {
      _step = 1;
      _categoryId = null;
      _subcategoryId = null;
      _search = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Handle ──
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                  ),
                  if (_categoryId != null)
                    GestureDetector(
                      onTap: _clear,
                      child: const Text('Clear', style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500)),
                    ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22, color: AppColors.tertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search category, subcategory or role...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: AppColors.border)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Step indicator ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StepDot(label: 'Category', active: _step >= 1, completed: _step > 1, onTap: () => setState(() => _step = 1)),
                  _StepLine(active: _step > 1),
                  _StepDot(label: 'Subcategory', active: _step >= 2, completed: _step > 2, onTap: _step >= 2 ? () => setState(() => _step = 2) : null),
                  _StepLine(active: _step > 2),
                  _StepDot(label: 'Role', active: _step >= 3, completed: false, onTap: null),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Content ──
            Expanded(
              child: _search.isNotEmpty ? _buildSearchResults(scrollController) : _buildStepContent(scrollController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(ScrollController controller) {
    if (_step == 1) return _buildCategoryList(controller);
    if (_step == 2) return _buildSubcategoryList(controller);
    return _buildRoleList(controller);
  }

  // ── Step 1: Categories ──
  Widget _buildCategoryList(ScrollController controller) {
    final popular = HospitalityCatalog.categories
        .where((c) => HospitalityCatalog.popularCategoryIds.contains(c.id))
        .toList();
    final rest = HospitalityCatalog.categories
        .where((c) => !HospitalityCatalog.popularCategoryIds.contains(c.id))
        .toList();

    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const _SectionHeader('Popular'),
        ...popular.map((c) => _CategoryRow(
          category: c,
          selected: c.id == _categoryId,
          onTap: () => setState(() { _categoryId = c.id; _subcategoryId = null; _step = 2; }),
        )),
        const SizedBox(height: 16),
        const _SectionHeader('All Categories'),
        ...rest.map((c) => _CategoryRow(
          category: c,
          selected: c.id == _categoryId,
          onTap: () => setState(() { _categoryId = c.id; _subcategoryId = null; _step = 2; }),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 2: Subcategories ──
  Widget _buildSubcategoryList(ScrollController controller) {
    final cat = _selectedCategory;
    if (cat == null) return const SizedBox.shrink();
    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _SectionHeader(cat.name),
        ...cat.subcategories.map((sub) => _SubcategoryRow(
          subcategory: sub,
          selected: sub.id == _subcategoryId,
          onTap: () => setState(() { _subcategoryId = sub.id; _step = 3; }),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Step 3: Roles ──
  Widget _buildRoleList(ScrollController controller) {
    final sub = _selectedSubcategory;
    if (sub == null) return const SizedBox.shrink();

    final popular = sub.roles.where((r) => HospitalityCatalog.popularRoles.contains(r)).toList();
    final rest = sub.roles.where((r) => !HospitalityCatalog.popularRoles.contains(r)).toList();

    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _SectionHeader(sub.name),
        if (popular.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Most Common', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tertiary)),
          ),
          ...popular.map((r) => _RoleRow(
            role: r,
            selected: r == widget.initialRoleId,
            onTap: () {
              widget.onSelected(_categoryId!, _subcategoryId!, r);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 8),
        ],
        if (rest.isNotEmpty) ...[
          ...rest.map((r) => _RoleRow(
            role: r,
            selected: r == widget.initialRoleId,
            onTap: () {
              widget.onSelected(_categoryId!, _subcategoryId!, r);
              Navigator.pop(context);
            },
          )),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Search results across all levels ──
  Widget _buildSearchResults(ScrollController controller) {
    final results = <_SearchResult>[];
    for (final cat in HospitalityCatalog.categories) {
      if (cat.name.toLowerCase().contains(_search)) {
        results.add(_SearchResult(cat.name, 'Category', AppColors.teal, () => setState(() { _categoryId = cat.id; _subcategoryId = null; _step = 2; _search = ''; })));
      }
      for (final sub in cat.subcategories) {
        if (sub.name.toLowerCase().contains(_search)) {
          results.add(_SearchResult('${sub.name}  ·  ${cat.name}', 'Subcategory', AppColors.indigo, () => setState(() { _categoryId = cat.id; _subcategoryId = sub.id; _step = 3; _search = ''; })));
        }
        for (final role in sub.roles) {
          if (role.toLowerCase().contains(_search)) {
            results.add(_SearchResult('$role  ·  ${sub.name}', 'Role', AppColors.amber, () {
              widget.onSelected(cat.id, sub.id, role);
              Navigator.pop(context);
            }));
          }
        }
      }
    }
    // Deduplicate by display text
    final seen = <String>{};
    final unique = results.where((r) => seen.add(r.text)).toList();

    return ListView(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('${unique.length} results', style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
        ),
        ...unique.take(50).map((r) => _SearchResultRow(result: r)),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Helper widgets ──

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
  );
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool active;
  final bool completed;
  final VoidCallback? onTap;
  const _StepDot({required this.label, required this.active, required this.completed, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppColors.teal : (active ? AppColors.tealLight : AppColors.surface),
            border: Border.all(color: active ? AppColors.teal : AppColors.border, width: 1.5),
          ),
          child: completed ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.teal : AppColors.tertiary, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ],
    ),
  );
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(height: 2, margin: const EdgeInsets.only(bottom: 18), color: active ? AppColors.teal : AppColors.divider),
  );
}

class _CategoryRow extends StatelessWidget {
  final HospitalityCategory category;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryRow({required this.category, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.tealLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: selected ? AppColors.teal : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.teal : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(child: Text(category.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                Text('${category.subcategories.length} subcategories', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check, size: 18, color: AppColors.teal),
          const SizedBox(width: 4),
          ForwardChevron(size: 18, color: AppColors.tertiary),
        ],
      ),
    ),
  );
}

class _SubcategoryRow extends StatelessWidget {
  final HospitalitySubcategory subcategory;
  final bool selected;
  final VoidCallback onTap;
  const _SubcategoryRow({required this.subcategory, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.tealLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: selected ? AppColors.teal : AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subcategory.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                Text('${subcategory.roles.length} roles', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
              ],
            ),
          ),
          if (selected) const Icon(Icons.check, size: 18, color: AppColors.teal),
          const SizedBox(width: 4),
          ForwardChevron(size: 18, color: AppColors.tertiary),
        ],
      ),
    ),
  );
}

class _RoleRow extends StatelessWidget {
  final String role;
  final bool selected;
  final VoidCallback onTap;
  const _RoleRow({required this.role, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.tealLight : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: selected ? AppColors.teal : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: const Icon(Icons.person_outline, size: 18, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(role, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal))),
          if (selected) const Icon(Icons.check, size: 18, color: AppColors.teal),
        ],
      ),
    ),
  );
}

class _SearchResult {
  final String text;
  final String kind;
  final Color color;
  final VoidCallback onTap;
  const _SearchResult(this.text, this.kind, this.color, this.onTap);
}

class _SearchResultRow extends StatelessWidget {
  final _SearchResult result;
  const _SearchResultRow({required this.result});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: result.onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: result.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
            child: Text(result.kind, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: result.color)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(result.text, style: const TextStyle(fontSize: 14, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
          ForwardChevron(size: 16, color: AppColors.tertiary),
        ],
      ),
    ),
  );
}
