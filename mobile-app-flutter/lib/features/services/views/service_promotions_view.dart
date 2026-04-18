import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Browse promotions & offers from service companies.
class ServicePromotionsView extends StatefulWidget {
  const ServicePromotionsView({super.key});

  @override
  State<ServicePromotionsView> createState() => _ServicePromotionsViewState();
}

class _ServicePromotionsViewState extends State<ServicePromotionsView> {
  static const _orange = Color(0xFFF97316);

  String _selectedFilter = 'All';
  final Set<String> _savedIds = {};

  static const _filters = ['All', 'Active', 'Expiring Soon', 'Nearby'];

  List<Map<String, dynamic>> get _promotions =>
      MockData.servicePromotions.cast<Map<String, dynamic>>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            const SizedBox(height: AppSpacing.sm),
            _filterChips(),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _promotionList()),
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
                child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Promotions & Offers',
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

  Widget _filterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: _filters
            .map((f) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color:
                            _selectedFilter == f ? _orange : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: _selectedFilter == f
                            ? null
                            : Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _selectedFilter == f
                                  ? Colors.white
                                  : AppColors.secondary)),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _promotionList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _promotions.length,
      itemBuilder: (_, i) => _promotionCard(_promotions[i]),
    );
  }

  Widget _promotionCard(Map<String, dynamic> p) {
    final id = p['id'] as String;
    final isSaved = _savedIds.contains(id);
    final initials = p['companyInitials'] as String;
    final hue = (initials.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.15, 0.95).toColor();
    final textColor = HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();

    return GestureDetector(
      onTap: () => context.push('/services/promotions/$id'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: const Border(
            left: BorderSide(color: _orange, width: 3),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: bgColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['company'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSaved) {
                        _savedIds.remove(id);
                      } else {
                        _savedIds.add(id);
                      }
                    });
                  },
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isSaved ? _orange : AppColors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(p['title'] as String,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            Text(p['description'] as String,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.secondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text('Valid until ${p['validUntil']}',
                    style: const TextStyle(fontSize: 11, color: _orange)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text('View Offer',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _orange)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
