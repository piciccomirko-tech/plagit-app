import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../common_modules/job_post_details/models/interested_request_model.dart';

class EmployeeJobPostsDetailsController extends GetxController {
  late Job jobPostDetails;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();

  @override
  void onInit() {
    jobPostDetails = Get.arguments;
    super.onInit();
  }

  void onDetailsClick() {
    (jobPostDetails.dates ?? []).sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: (jobPostDetails.dates ?? []));
  }

  void calculatePreviousDates({required List<RequestDateModel> bookedDateList}) {
    for (var i in bookedDateList) {
      if (DateTime.parse(i.endDate ?? '').toString().substring(0, 10) == DateTime.now().toString().substring(0, 10)) {
        i.status = '';
      } else if (DateTime.parse(i.endDate ?? '').isBefore(DateTime.now())) {
        i.status = 'Done';
      } else {
        i.status = '';
      }
    }
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: bookedDateList));
  }

  void showInterest({required BuildContext context}) async {
    CustomLoader.show(context);
    InterestedRequestModel interestedRequestModel =
        InterestedRequestModel(id: jobPostDetails.id ?? "", employeeId: appController.user.value.employee?.id ?? "");
    Either<CustomError, Response> responseData =
        await _apiHelper.interested(interestedRequestModel: interestedRequestModel);
    Get.back();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context, customError);
    }, (Response response) {
      if ([200, 201].contains(response.statusCode)) {
        Get.find<EmployeeHomeController>().getJobPosts();
        Get.back();
        Utils.showSnackBar(message: MyStrings.thanksForShowingInterest.tr, isTrue: true);
      } else {
        Utils.showSnackBar(message: MyStrings.somethingWentWrong.tr, isTrue: false);
      }
    });
  }

  bool get showInterestedButton => appController.user.value.employee?.positionName == jobPostDetails.positionId?.name;
}
