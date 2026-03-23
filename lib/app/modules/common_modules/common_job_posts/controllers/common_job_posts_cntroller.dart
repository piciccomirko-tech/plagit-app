import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class CommonJobPostsController extends GetxController {
  String? clientId;
  String? clientName;
  bool? isMyJobPost;
  bool? isSocketCall;
  String userType;

  CommonJobPostsController(
      {this.clientId, this.isMyJobPost, this.isSocketCall,required this.userType, this.clientName});
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  RxList<Job> jobPostList = <Job>[].obs;
  RxBool jobPostDataLoaded = false.obs;

  RxList<Job> myJobPostList = <Job>[].obs;
  RxBool myJobPostDataLoaded = false.obs;
  RxInt jobCurrentPage = 1.obs;
  RxBool moreJobPostsAvailable = false.obs;

// Pagination Variables
  RxInt myJobCurrentPage = 1.obs;
  final int itemsMyJobPerPage = 3; // Items per page
  RxInt totalMyJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalMyJobPosts = 0.obs; // Total items fetched from the API
// Pagination Variables for all job posts
  RxInt allJobCurrentPage = 1.obs;
  final int itemsAllJobPerPage = 6; // Items per page
  RxInt totalAllJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalAllJobPosts = 0.obs; // Total items fetched from the API

  @override
  void onInit() {
    super.onInit();
    debugPrint(isMyJobPost.toString());
   if( isMyJobPost!=null && isMyJobPost==true ) {
      getMyJobPosts();
    }else {
      getJobPosts();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> getMyJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      myJobPostDataLoaded.value = false;
    } else {
      myJobPostDataLoaded.value = true;
    }
    // log("Fetching My Job Posts for Page: $page"); // Debugging
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
      page: page,
      isMyJobPost: true, // Ensure this parameter filters only "my job posts"
      userType: userType,
      status: "PUBLISHED", //doesnt matter if isMyJobpost is true
      limit:
          itemsMyJobPerPage, // Adjust to match API's limit parameter if applicable
    );
    if (isSocketCall == false) myJobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        myJobPostList.value = response.jobs ?? [];
        totalMyJobPosts.value = response.total ?? 0; // Update total items count
        grossTotalMyJobPosts.value =
            response.total ?? 0; // Update total items count
        updateTotalMyJobPostPages(); // Recalculate total pages
        log("Loaded ${response.jobs?.length ?? 0} jobs for page $page"); // Debugging
      } else {
        log("Failed to load My Job Posts for Page: $page"); // Debugging
      }
    });
    myJobPostList.refresh();
  }

  void updateTotalMyJobPostPages() {
    totalMyJobPosts.value = (totalMyJobPosts.value / itemsMyJobPerPage).ceil();
  }

  void updateTotalAllJobPostPages() {
    totalAllJobPosts.value =
        (totalAllJobPosts.value / itemsAllJobPerPage).ceil();
  }

  void goToMyJobNextPage() {
    if (myJobCurrentPage.value < totalMyJobPosts.value) {
      myJobCurrentPage.value++;
      getMyJobPosts(
          page: myJobCurrentPage.value); // Load data for the next page
    }
  }

  void goToMyJobPreviousPage() {
    if (myJobCurrentPage.value > 1) {
      myJobCurrentPage.value--;
      getMyJobPosts(
          page: myJobCurrentPage.value); // Load data for the previous page
    }
  }

  void goToAllJobNextPage() {
    if (allJobCurrentPage.value < totalAllJobPosts.value) {
      allJobCurrentPage.value++;
      getJobPosts(page: allJobCurrentPage.value); // Load data for the next page
    }
  }

  void goToAllJobPreviousPage() {
    if (allJobCurrentPage.value > 1) {
      allJobCurrentPage.value--;
      getJobPosts(
          page: allJobCurrentPage.value); // Load data for the previous page
    }
  }

  int get totalPages => (totalMyJobPosts.value / itemsMyJobPerPage).ceil();

  void onFullViewClick({required String jobPostId, bool? isMyJobPost}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: {
        "jobPostId": jobPostId,
        'isMyJobPost': isMyJobPost,
      });

  void onJobDetailsClick(
          {required String jobPostId, bool isMyJobPost = false}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);

  void onEditClick({required Job jobRequest}) =>
      Get.toNamed(Routes.createJobPost,
          arguments: CreateJobPostRequestModel(
            id: jobRequest.id ?? "",
            positionId: jobRequest.positionId?.id ?? "",
            clientId: appController.user.value.client?.id ?? "",
            // minRatePerHour: jobRequest.minRatePerHour ?? "0.0",
            // maxRatePerHour: jobRequest.maxRatePerHour ?? "0.0",
            salary: jobRequest.salary ?? '',
            age: jobRequest.age ?? '',
            experience: jobRequest.experience,
            vacancy: jobRequest.vacancy ?? 0,
            dates: jobRequest.dates ?? [],
            nationalities: jobRequest.nationalities ?? [],
            skills: jobRequest.skills ?? [],
            // minExperience: jobRequest.minExperience ?? 0,
            // maxExperience: jobRequest.maxExperience ?? 0,
            languages: jobRequest.languages ?? [],
            description: jobRequest.description ?? "",
            publishedDate: jobRequest.publishedDate,
            endDate: jobRequest.endDate,
          )
          // minAge: jobRequest.minAge,
          // maxAge: jobRequest.maxAge)
          );

  void onDeleteClick({required String jobId}) async {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: MyStrings.areYouSureDeleteJobRequest.tr,
      confirmButtonText: MyStrings.delete.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(Get.context!);
        Either<CustomError, CommonResponseModel> responseData =
            await _apiHelper.deleteJobPost(jobId: jobId);
        CustomLoader.hide(Get.context!);

        responseData.fold((CustomError customError) {
          Utils.errorDialog(Get.context!, customError);
        }, (CommonResponseModel response) {
          if (response.status == "success" && response.statusCode == 200) {
            getJobPosts();
            getMyJobPosts();
            FocusScope.of(Get.context!).unfocus();
            Utils.showSnackBar(
                message: response.message ??
                    MyStrings.jobRequestDeletedSuccessfully.tr,
                isTrue: true);
          }
        });
      },
    );
  }

  Future<void> _getMoreJobPosts() async {
    Either<CustomError, JobPostRequestModel> responseData = await _apiHelper
        .getJobPosts(page: jobCurrentPage.value, userType: "client");
    jobPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      moreJobPostsAvailable.value = false;
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        if ((response.jobs ?? []).isNotEmpty) {
          moreJobPostsAvailable.value = true;
        } else {
          moreJobPostsAvailable.value = false;
        }
        jobPostList.addAll(response.jobs ?? []);
      }
    });
    jobPostList.refresh();
  }

  Future<void> getJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      jobPostDataLoaded.value = false;
    } else {
      jobPostDataLoaded.value = true;
    }
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
          jobPostForUserId: clientId??'',
            page: page,
            limit:
                itemsAllJobPerPage, // Adjust to match API's limit parameter if applicable,
            userType: userType,
            status: "PUBLISHED",
            isMyJobPost: false);
    if (isSocketCall == false) jobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        jobPostList.value = response.jobs ?? [];

        totalAllJobPosts.value =
            response.total ?? 0; // Update total items count
        grossTotalAllJobPosts.value =
            response.total ?? 0; // Update total items count that won't update

        updateTotalAllJobPostPages(); // Recalculate total pages
      }
    });
    jobPostList.refresh();
  }
}
