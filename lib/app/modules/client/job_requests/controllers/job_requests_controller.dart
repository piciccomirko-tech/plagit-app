import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class JobRequestsController extends GetxController {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  final AppController _appController = Get.find<AppController>();

  Rx<JobPostRequestModel> jobPostRequest = JobPostRequestModel().obs;
  RxBool jobPostDataLoading = false.obs;

  @override
  void onInit() {
    getJobRequests();
    super.onInit();
  }

  void getJobRequests() async {
    jobPostDataLoading.value = true;
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobRequests(userType: "CLIENT", clientId: _appController.user.value.client?.id ?? "");
    jobPostDataLoading.value = false;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = getJobRequests);
    }, (JobPostRequestModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        jobPostRequest.value = response;
        jobPostRequest.refresh();
      }
    });
  }

  void onEditClick({required Job jobRequest}) => Get.toNamed(Routes.createJobPost,
      arguments: CreateJobPostRequestModel(
          id: jobRequest.id ?? "",
          positionId: jobRequest.positionId?.id ?? "",
          clientId: _appController.user.value.client?.id ?? "",
          minRatePerHour: jobRequest.minRatePerHour ?? 0.0,
          maxRatePerHour: jobRequest.maxRatePerHour ?? 0.0,
          vacancy: jobRequest.vacancy ?? 0,
          dates: jobRequest.dates ?? [],
          nationalities: jobRequest.nationalities ?? [],
          skills: jobRequest.skills ?? [],
          minExperience: jobRequest.minExperience ?? 0,
          maxExperience: jobRequest.maxExperience ?? 0,
          languages: jobRequest.languages ?? [],
          description: jobRequest.description ?? "",
          publishedDate: jobRequest.publishedDate,
          endDate: jobRequest.endDate,
          minAge: jobRequest.minAge,
          maxAge: jobRequest.maxAge));

  void onDeleteClick({required String jobId}) async {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: "Are you sure you want to delete this job request?",
      confirmButtonText: "Delete",
      onConfirm: () async {
        Get.back();

        CustomLoader.show(context!);
        Either<CustomError, CommonResponseModel> responseData = await _apiHelper.deleteJobPost(jobId: jobId);
        CustomLoader.hide(context!);

        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (CommonResponseModel response) {
          if (response.status == "success" && response.statusCode == 200) {
            getJobRequests();
            Utils.showSnackBar(message: response.message ?? "Job request has been deleted successfully", isTrue: true);
          }
        });
      },
    );
  }

  void onJobDetailsClick({required Job jobDetails}) => Get.toNamed(Routes.jobRequestDetails, arguments: jobDetails);
}
