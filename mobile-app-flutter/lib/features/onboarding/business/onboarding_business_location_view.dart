import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

class OnboardingBusinessLocationView extends StatefulWidget {
  const OnboardingBusinessLocationView({super.key});

  @override
  State<OnboardingBusinessLocationView> createState() => _OnboardingBusinessLocationViewState();
}

class _OnboardingBusinessLocationViewState extends State<OnboardingBusinessLocationView> {
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
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

              // ── Back + Progress bar 4/5 ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 22, color: AppColors.charcoal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _ProgressBar(current: 4, total: 5)),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Where is your business located?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),
              ),

              const SizedBox(height: 24),

              // ── Form card ──
              Container(
                decoration: AppColors.cardDecoration,
                child: Column(
                  children: [
                    _buildField(Icons.location_on_outlined, 'Address', _addressCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.location_city_outlined, 'City', _cityCtrl),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildField(Icons.flag_outlined, 'Country', _countryCtrl),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Use current location ──
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.my_location, size: 18, color: AppColors.teal),
                  label: const Text(
                    'Use current location',
                    style: TextStyle(fontSize: 14, color: AppColors.teal, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const Spacer(),

              // ── Next button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/business/onboarding/profile'),
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

  Widget _buildField(IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
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
