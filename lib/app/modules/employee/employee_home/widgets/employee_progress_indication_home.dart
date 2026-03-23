import 'package:mh/app/common/utils/exports.dart';

import '../controllers/employee_home_controller.dart';


class EmployeeProgressIndicatorHomeWidget
    extends GetView<EmployeeHomeController> {
  final double progress;
  final String message;

  const EmployeeProgressIndicatorHomeWidget({
    super.key,
    required this.progress,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: Utils.percentageIndicatorGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator with percentage
          SizedBox(
            height: 50,
            width: 50,
            child: Obx(() {
              double progressValue = (controller.userProfileCompletionDetails
                          ?.value?.profileCompleted ??
                      0) /
                  100;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Text("${progressValue}"),
                  CircularProgressIndicator(
                    value: progressValue,
                    // backgroundColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Color(0xff111111).withOpacity(.3),
                    color: Colors.white,
                    strokeWidth: 6,
                  ),
                  Center(
                    child: Text(
                      '${(progressValue * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(width: 16), // Space between indicator and message
          // Progress Message Text
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
