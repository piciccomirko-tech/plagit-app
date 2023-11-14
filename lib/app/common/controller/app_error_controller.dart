import '../../repository/api_helper.dart';
import '../utils/exports.dart';
import 'app_controller.dart';

class AppErrorController {
  static void submitAutomaticError({String errorName = 'undefine', String description = 'no error'}) {
    if(Get.isRegistered<ApiHelper>()) {

      String userId = "";
      if(Get.isRegistered<AppController>()) {
        AppController appController = Get.find();
        userId = appController.user.value.userId;
      }

      final ApiHelper apiHelper = Get.find();

      apiHelper.submitAppError({
        "name" : errorName,
        "userId": userId,
        'description' : description,
      });
    }
  }
}