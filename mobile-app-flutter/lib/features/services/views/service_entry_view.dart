import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Service entry screen — replica of ServiceEntryView.swift.
/// Two options: Register as a Business / I'm Looking for a Business.
class ServiceEntryView extends StatelessWidget {
  const ServiceEntryView({super.key});

  static const _rounded = TextStyle(fontFamily: '.AppleSystemUIFontRounded');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ──
          // Swift: HStack, horizontal padding 20, top/bottom padding 16
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 36, height: 36,
                  child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal),
                ),
              ),
              const Spacer(),
              // Swift: PlagitFont.subheadline() = 15pt medium
              const Text(
                'Looking for Companies',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal),
              ),
              const Spacer(),
              const SizedBox(width: 36, height: 36),
            ]),
          ),

          const Spacer(),

          // ── Header ──
          // Swift: VStack(spacing: PlagitSpacing.md = 12)
          Column(children: [
            // Circle icon: 64px amber 0.1, icon 28pt
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apartment, size: 28, color: AppColors.amber),
            ),
            const SizedBox(height: 12), // PlagitSpacing.md

            // Title: 22pt bold rounded
            Text(
              'Hospitality Services',
              style: _rounded.copyWith(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal),
            ),
            const SizedBox(height: 12), // PlagitSpacing.md

            // Subtitle: 15pt body secondary, centered, lineSpacing 3, horizontal padding 20
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Register your service company or find hospitality providers near you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.secondary, height: 1.45),
              ),
            ),
          ]),

          const SizedBox(height: 32), // Spacer().frame(height: PlagitSpacing.xxxl)

          // ── Option cards ──
          // Swift: VStack(spacing: PlagitSpacing.md = 12), padding .horizontal 20
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              _OptionCard(
                icon: Icons.add_circle,
                color: AppColors.amber,
                title: 'Register as a Business',
                subtitle: 'List your hospitality service and get discovered by clients',
                onTap: () {
                  // Future: navigate to ServiceProviderSignUpView
                  _showComingSoon(context);
                },
              ),
              const SizedBox(height: 12), // PlagitSpacing.md
              _OptionCard(
                icon: Icons.search,
                color: AppColors.teal,
                title: "I'm Looking for a Business",
                subtitle: 'Find hospitality service providers near you',
                onTap: () {
                  // Future: navigate to ServiceFeedView
                  _showComingSoon(context);
                },
              ),
            ]),
          ),

          const Spacer(),
        ]),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Coming Soon', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        content: const Text(
          'This feature is currently in development and will be available in a future update.',
          style: TextStyle(color: AppColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Option card — same structure as EntryView roleCard / Swift optionCard.
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const _rounded = TextStyle(fontFamily: '.AppleSystemUIFontRounded');

  const _OptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20), // PlagitSpacing.xl
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20), // PlagitRadius.xl
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Row(children: [
          // Icon badge: 52x52, radius 16, color.opacity(0.1)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16), // PlagitRadius.lg
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16), // PlagitSpacing.lg

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _rounded.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                ),
                const SizedBox(height: 4), // PlagitSpacing.xs
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Arrow circle
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward, size: 18, color: color),
          ),
        ]),
      ),
    );
  }
}
