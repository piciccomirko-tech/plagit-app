import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/models/interested_request_model.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeJobPostsDetailsController extends GetxController {
  late Job jobPostDetails;
  final ApiHelper _apiHelper = Get.find();
  final AppController _appController = Get.find<AppController>();
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
        InterestedRequestModel(id: jobPostDetails.id ?? "", employeeId: _appController.user.value.employee?.id ?? "");
    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.interested(interestedRequestModel: interestedRequestModel);
    Get.back();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context, customError);
    }, (CommonResponseModel response) {
      if (response.status == "success" && [200, 201].contains(response.statusCode)) {
        Get.back();
        Utils.showSnackBar(message: response.message ?? "Thanks for showing interest", isTrue: true);
      }
    });
  }

  bool get showInterestedButton => _appController.user.value.employee?.positionName == jobPostDetails.positionId?.name;
}
