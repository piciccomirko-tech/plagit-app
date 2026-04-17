import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Map placeholder showing nearby service companies as pins.
class ServiceMapView extends StatelessWidget {
  const ServiceMapView({super.key});

  List<Map<String, dynamic>> get _companies =>
      MockData.londonCompanies;

  // Mock pin positions (fractional offsets within the map area)
  static const _pinPositions = [
    Offset(0.3, 0.25),
    Offset(0.55, 0.35),
    Offset(0.2, 0.5),
    Offset(0.7, 0.45),
    Offset(0.45, 0.65),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: Stack(
                children: [
                  // Map placeholder
                  Container(
                    color: const Color(0xFFE8E8E8),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map,
                              size: 48,
                              color: AppColors.tertiary.withValues(alpha: 0.5)),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Map view',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.tertiary
                                      .withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                  ),

                  // Pins
                  ..._buildPins(context),

                  // Bottom sheet with company cards
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _bottomSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
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
          const Text('Nearby Companies',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text('List',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPins(BuildContext context) {
    final companies = _companies;
    final count =
        companies.length < _pinPositions.length ? companies.length : _pinPositions.length;

    return List.generate(count, (i) {
      return LayoutBuilder(builder: (ctx, constraints) {
        // Use a FractionallySizedBox approach via Positioned
        return Positioned(
          left: _pinPositions[i].dx *
              (MediaQuery.of(context).size.width - 40),
          top: _pinPositions[i].dy * 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(companies[i]['name'] as String,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal)),
              ),
              const Icon(Icons.location_on,
                  size: 28, color: AppColors.teal),
            ],
          ),
        );
      });
    });
  }

  Widget _bottomSheet(BuildContext context) {
    final companies = _companies;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text('${companies.length} companies nearby',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary)),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              itemCount: companies.length,
              itemBuilder: (_, i) {
                final c = companies[i];
                final initials = c['initials'] as String;
                final hue =
                    (initials.hashCode % 360).abs().toDouble();
                final bgColor =
                    HSLColor.fromAHSL(1, hue, 0.15, 0.95).toColor();
                final textColor =
                    HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();

                return GestureDetector(
                  onTap: () =>
                      context.push('/services/companies/${c['id']}'),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.lg),
                      border:
                          Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.sm)),
                              alignment: Alignment.center,
                              child: Text(initials,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(c['name'] as String,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.charcoal),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(c['subcategory'] as String,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.teal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.near_me,
                                size: 10, color: AppColors.tertiary),
                            const SizedBox(width: 2),
                            Text(c['distance'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.tertiary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
