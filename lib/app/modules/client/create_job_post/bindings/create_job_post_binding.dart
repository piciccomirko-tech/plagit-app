import 'package:get/get.dart';

import '../controllers/create_job_post_controller.dart';
import '../controllers/slider_controller.dart';

class CreateJobPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateJobPostController>(
      () => CreateJobPostController(),
    );
        Get.lazyPut<SliderController>(() => SliderController());

  }
}
