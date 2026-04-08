import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';

class OnboardingBusinessProfileView extends StatefulWidget {
  const OnboardingBusinessProfileView({super.key});

  @override
  State<OnboardingBusinessProfileView> createState() => _OnboardingBusinessProfileViewState();
}

class _OnboardingBusinessProfileViewState extends State<OnboardingBusinessProfileView> {
  final _descriptionCtrl = TextEditingController();
  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _descriptionCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charCount = _descriptionCtrl.text.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Back + Progress bar 5/5 ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios, size: 22, color: AppColors.charcoal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _ProgressBar(current: 5, total: 5)),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Complete your business profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),
              ),

              const SizedBox(height: 24),

              // ── Logo upload area ──
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'TB',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.charcoal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Description label ──
              const Text(
                'Business description',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),

              const SizedBox(height: 8),

              // ── TextArea ──
              Container(
                decoration: AppColors.cardDecoration,
                child: TextField(
                  controller: _descriptionCtrl,
                  maxLines: 6,
                  maxLength: _maxChars,
                  decoration: InputDecoration(
                    hintText: 'Describe your business, culture, and what makes it a great place to work... (min 150 characters suggested)',
                    hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    counterText: '$charCount / $_maxChars',
                    counterStyle: TextStyle(
                      fontSize: 12,
                      color: charCount >= _maxChars ? AppColors.red : AppColors.tertiary,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ── Finish Setup button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/business/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Finish Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
