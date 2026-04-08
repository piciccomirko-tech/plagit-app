import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Detail view for a hospitality service provider.
/// Mirrors ServiceCompanyProfileView.swift.
class ServiceCompanyProfileView extends StatelessWidget {
  const ServiceCompanyProfileView({super.key});

  // Mock data
  static const _name = 'Elite Catering Co.';
  static const _initials = 'EC';
  static const _hue = 0.1;
  static const _subcategory = 'Event Catering';
  static const _category = 'Catering';
  static const _location = 'London, UK';
  static const _rating = 4.8;
  static const _reviewCount = 124;
  static const _isVerified = true;
  static const _description =
      'Elite Catering Co. has been providing premium catering services for over 15 years. '
      'We specialize in corporate events, weddings, private dining, and large-scale galas. '
      'Our team of experienced chefs creates bespoke menus using locally sourced, seasonal ingredients. '
      'We pride ourselves on exceptional service and attention to detail.';

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromAHSL(1, _hue * 360, 0.15, 0.95);
    final hslText = HSLColor.fromAHSL(1, _hue * 360, 0.6, 0.5);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
                  ),
                  const Spacer(),
                  const Text('Company Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Spacer(),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Column(
                  children: [
                    // ── Hero card ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(color: hsl.toColor(), borderRadius: BorderRadius.circular(AppRadius.xl)),
                                  alignment: Alignment.center,
                                  child: Text(_initials, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: hslText.toColor())),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const Flexible(child: Text(_name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
                                        if (_isVerified) ...[const SizedBox(width: AppSpacing.sm), const Icon(Icons.verified, size: 16, color: AppColors.teal)],
                                      ]),
                                      const SizedBox(height: AppSpacing.xs),
                                      const Text(_subcategory, style: TextStyle(fontSize: 15, color: AppColors.teal)),
                                      const SizedBox(height: AppSpacing.xs),
                                      const Row(children: [
                                        Icon(Icons.location_on, size: 12, color: AppColors.teal),
                                        SizedBox(width: AppSpacing.xs),
                                        Text(_location, style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            // Rating bar
                            Row(
                              children: [
                                ...List.generate(5, (i) {
                                  return Icon(
                                    i + 0.5 < _rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: AppColors.amber,
                                  );
                                }),
                                const SizedBox(width: AppSpacing.xs),
                                const Text('$_rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                                const SizedBox(width: AppSpacing.lg),
                                const Text('$_reviewCount reviews', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                                  child: const Text(_category, style: TextStyle(fontSize: 11, color: AppColors.amber)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // ── About card ──
                    _sectionCard(
                      title: 'About',
                      child: const Text(_description, style: TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.5)),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // ── Details card ──
                    _sectionCard(
                      title: 'Details',
                      child: Column(
                        children: [
                          _detailRow(Icons.work, 'Category', _category),
                          const SizedBox(height: AppSpacing.lg),
                          _detailRow(Icons.sell, 'Specialty', _subcategory),
                          const SizedBox(height: AppSpacing.lg),
                          _detailRow(Icons.location_on, 'Location', _location),
                          const SizedBox(height: AppSpacing.lg),
                          _detailRow(Icons.verified_user, 'Verified', _isVerified ? 'Yes' : 'Pending'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // ── Contact buttons ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        children: [
                          // Contact button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.amber, Color(0xDDF59E33)]),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email, size: 16, color: Colors.white),
                                  SizedBox(width: AppSpacing.sm),
                                  Text('Contact Company', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Call button
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.amber.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone, size: 16, color: AppColors.amber),
                                  SizedBox(width: AppSpacing.sm),
                                  Text('Call', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.amber)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.teal),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
          ],
        ),
      ],
    );
  }
}
