import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class OnboardingAvailabilityView extends StatefulWidget {
  const OnboardingAvailabilityView({super.key});

  @override
  State<OnboardingAvailabilityView> createState() =>
      _OnboardingAvailabilityViewState();
}

class _OnboardingAvailabilityViewState
    extends State<OnboardingAvailabilityView> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressBar(5),
              const SizedBox(height: 12),
              _buildBackButton(context),
              const SizedBox(height: 24),
              const Text(
                'What are you looking for?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: MockData.availabilityOptions.map((option) {
                  final isSelected = _selected.contains(option);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(option);
                        } else {
                          _selected.add(option);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppColors.teal,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.teal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: hasSelection
                      ? () => context.go('/candidate/home')
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
                  child: const Text('Finish Setup'),
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
      onTap: () => context.go('/onboarding/experience'),
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
