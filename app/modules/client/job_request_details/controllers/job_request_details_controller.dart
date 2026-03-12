import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/client/common/shortlist_controller.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/routes/app_pages.dart';

class JobRequestDetailsController extends GetxController {
  late Job jobDetails;
  final ShortlistController shortlistController = Get.find<ShortlistController>();
  final AppController _appController = Get.find<AppController>();

  @override
  void onInit() {
    jobDetails = Get.arguments;
    super.onInit();
  }

  Future<void> onBookNowClick({required String employeeId}) async {
    if (!_appController.hasPermission()) return;
    Get.toNamed(Routes.calender, arguments: [employeeId, shortListId(employeeId: employeeId), false]);
  }

  String shortListId({required String employeeId}) {
    for (var i in shortlistController.shortList) {
      if (i.employeeId == employeeId) {
        return i.sId ?? '';
      }
    }
    return '';
  }
}
