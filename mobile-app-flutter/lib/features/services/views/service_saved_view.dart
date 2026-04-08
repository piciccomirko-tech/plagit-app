import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';

/// View for saved / bookmarked service companies.
class ServiceSavedView extends StatefulWidget {
  const ServiceSavedView({super.key});

  @override
  State<ServiceSavedView> createState() => _ServiceSavedViewState();
}

class _ServiceSavedViewState extends State<ServiceSavedView> {
  late Set<String> _savedIds;

  @override
  void initState() {
    super.initState();
    _savedIds = Set<String>.from(MockData.serviceSavedCompanyIds);
  }

  List<Map<String, dynamic>> get _savedCompanies {
    final all = MockData.serviceCompanies.cast<Map<String, dynamic>>();
    return all.where((c) => _savedIds.contains(c['id'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            if (_savedIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${_savedIds.length} saved',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.secondary)),
                ),
              ),
            Expanded(
              child:
                  _savedCompanies.isEmpty ? _emptyState() : _companyList(),
            ),
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
          const Text('Saved Companies',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _companyList() {
    final list = _savedCompanies;
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
        child: Row(
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
                    ],
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(c['category'] as String,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.amber)),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.teal),
                      const SizedBox(width: AppSpacing.xs),
                      Text(c['location'] as String,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _confirmRemove(c['id'] as String),
              child: const Icon(Icons.favorite,
                  size: 22, color: AppColors.teal),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove?'),
        content: const Text(
            'Are you sure you want to remove this company from your saved list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _savedIds.remove(id));
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.urgent)),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.favorite_border,
                  size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No saved companies',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text('Save companies you like to find them easily later',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () => context.push('/services/discover'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text('Discover Companies',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
