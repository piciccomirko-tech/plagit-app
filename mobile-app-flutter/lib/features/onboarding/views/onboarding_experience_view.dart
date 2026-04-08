import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class OnboardingExperienceView extends StatefulWidget {
  const OnboardingExperienceView({super.key});

  @override
  State<OnboardingExperienceView> createState() =>
      _OnboardingExperienceViewState();
}

class _OnboardingExperienceViewState extends State<OnboardingExperienceView> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(4),
              const SizedBox(height: 12),
              _buildBackButton(context),
              const SizedBox(height: 24),
              const Text(
                'How much experience do you have?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: MockData.experienceOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = MockData.experienceOptions[index];
                    final isSelected = _selected == option;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = option),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.teal : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.teal,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: hasSelection
                      ? () => context.go('/onboarding/availability')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        hasSelection ? AppColors.teal : AppColors.border,
                    foregroundColor:
                        hasSelection ? Colors.white : AppColors.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Next'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/onboarding/location'),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_back_ios, size: 18, color: AppColors.charcoal),
          SizedBox(width: 4),
          Text(
            'Back',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.charcoal,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Row(
      children: List.generate(5, (index) {
        final step = index + 1;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: step < 5 ? 6 : 0),
            decoration: BoxDecoration(
              color: step <= currentStep ? AppColors.teal : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
