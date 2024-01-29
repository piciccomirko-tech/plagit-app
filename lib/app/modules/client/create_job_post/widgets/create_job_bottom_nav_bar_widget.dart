import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class CreateJobBottomNavBarWidget extends GetWidget<CreateJobPostController> {
  const CreateJobBottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBottomBar(
      child: CustomButtons.button(
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
          text: controller.type == "create"
              ? MyStrings.postJobOffer.tr.toUpperCase()
              : MyStrings.updateJobOffer.tr.toUpperCase(),
          onTap: controller.type == "create" ? controller.onPostJobClick : controller.onUpdateJobClick),
    );
  }
}
