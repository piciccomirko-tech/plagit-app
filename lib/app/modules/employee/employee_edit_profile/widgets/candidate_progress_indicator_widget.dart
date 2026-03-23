import 'package:mh/app/common/utils/exports.dart';
import '../controllers/employee_edit_profile_controller.dart';

class CandidateProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  final String message;

   CandidateProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.message,
  });
  final EmployeeEditProfileController controller = Get.find<EmployeeEditProfileController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: Utils.primaryGradient, // Teal background color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator with percentage
          SizedBox(
            height: 50,
            width: 50,
            child:  Obx(() {
               double progressValue = controller.profileCompleted.value / 100;
               return Stack(
              fit: StackFit.expand,
              children: [
              
                
             CircularProgressIndicator(
                  value: progressValue,
                  // backgroundColor: Colors.white.withOpacity(0.3),
                  backgroundColor: Color(0xff111111).withOpacity(.3),
                  color: Colors.white,
                  strokeWidth: 6,
                ),
                Center(
                  child: Text(
                    '${(controller.profileCompleted.value).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,fontFamily: MyAssets.fontKlavika,
                    ),
                  ),
                ),
              ],
            );}),
          ),
          const SizedBox(width: 16), // Space between indicator and message
          // Progress Message Text
          Expanded(
            child: Text(
              message,
              style:  TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,fontFamily: MyAssets.fontKlavika,
              ),
            ),
          ),
        ],
      ),
    );
  
  }
}
