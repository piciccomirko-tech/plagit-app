import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';

class StepsRowWidget extends StatelessWidget {
  final int currentStep;
  final double progress;
  final ValueChanged<int> onStepTapped;

  const StepsRowWidget({
    super.key,
    required this.currentStep,
    required this.progress,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Define icons and their labels
    List<Map<String, dynamic>> steps = [
      {'icon': CupertinoIcons.person, 'label': 'Profile', 'isRequired': true},
      {'icon': CupertinoIcons.creditcard, 'label': 'Card', 'isRequired': false},
      {
        'icon': CupertinoIcons.building_2_fill,
        'label': 'Business',
        'isRequired': false
      },
      {'icon': CupertinoIcons.archivebox, 'label': 'Bank', 'isRequired': false},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 == 0) {
          // Step icon with label
          int stepIndex = index ~/ 2;
          bool isCompleted = stepIndex < currentStep;
          bool isCurrent = stepIndex == currentStep;

          return GestureDetector(
            onTap: isCompleted || isCurrent
                ? () => onStepTapped(stepIndex)
                : () => onStepTapped(stepIndex),
            // : null, // Only allow taps on completed or current steps
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? MyColors.primaryLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isCurrent
                        ? Border.all(color: MyColors.primaryLight, width: 2)
                        : null,
                  ),
                  child: Icon(
                    steps[stepIndex]['icon'],
                    size: 24,
                    color: isCompleted
                        ? Colors.white
                        : isCurrent
                            ? MyColors.primaryLight
                            : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                // Label below the icon
                Column(
                  children: [
                    Text(steps[stepIndex]['label'],
                        style: (isCompleted || isCurrent)
                            ? MyColors.primaryLight.medium12
                            : MyColors.lightGrey.medium12),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text( steps[stepIndex]['isRequired']? '(Required)': '(Optional)',
                        style: (isCompleted || isCurrent)
                            ? MyColors.primaryLight.medium12.copyWith(fontSize: 8.sp)
                            : MyColors.lightGrey.medium12.copyWith(fontSize: 8.sp)),

                  ],
                ),
         
                
              ],
            ),
          );
        } else {
          // Horizontal Line between steps
          return Expanded(
            child: Container(
              height: 2,
              color: index ~/ 2 < currentStep
                  ? MyColors.primaryLight
                  : Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }
      }),
    );
  }
}
