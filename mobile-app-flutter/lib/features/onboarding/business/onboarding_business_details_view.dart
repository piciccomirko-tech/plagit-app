import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

class OnboardingBusinessDetailsView extends StatefulWidget {
  const OnboardingBusinessDetailsView({super.key});

  @override
  State<OnboardingBusinessDetailsView> createState() => _OnboardingBusinessDetailsViewState();
}

class _OnboardingBusinessDetailsViewState extends State<OnboardingBusinessDetailsView> {
  final _businessNameCtrl = TextEditingController(text: 'The Grand London');
  final _contactPersonCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _contactPersonCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Back + Progress bar 3/5 ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 22, color: AppColors.charcoal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _ProgressBar(current: 3, total: 5)),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Tell us about your business',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),
              ),

              const SizedBox(height: 24),

              // ── Form card ──
              Container(
                decoration: AppColors.cardDecoration,
                child: Column(
                  children: [
                    _buildField(Icons.business_outlined, 'Business name', _businessNameCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.person_outline, 'Contact person', _contactPersonCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.phone_outlined, 'Phone number', _phoneCtrl, keyboardType: TextInputType.phone),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.language, 'www.example.com', _websiteCtrl, keyboardType: TextInputType.url),
                  ],
                ),
              ),

              const Spacer(),

              // ── Next button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/business/onboarding/location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String hint, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 15),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppColors.teal : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
