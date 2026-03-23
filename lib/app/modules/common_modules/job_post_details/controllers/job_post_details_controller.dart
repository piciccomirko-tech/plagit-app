import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/job_post_details_response_model.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/common/shortlist_controller.dart';
import 'package:mh/app/modules/common_modules/job_post_details/models/interested_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/employee/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../models/social_feed_response_model.dart';
import '../../../admin/chat_it/controllers/chat_it_controller.dart';
import '../../live_chat/models/conversation_create_request_model.dart';
import '../../live_chat/models/conversation_response_model.dart';
import '../widgets/job_details_months_widget.dart';

class JobPostDetailsController extends GetxController {
  BuildContext? context;
  String jobPostId = '';
  RxBool isMyJobPost = false.obs;

  final ShortlistController shortlistController =
      Get.find<ShortlistController>();
  final AppController appController = Get.find<AppController>();
  final ApiHelper _apiHelper = Get.find<ApiHelper>();

  RxBool isFetching = false.obs;
  var isFetchingId = '0'.obs;
  Rx<Job> jobPostDetails = Job().obs;
  RxBool jobPostDetailsDataLoading = true.obs;
  RxBool noDataFound = false.obs;
  final ChatItController chatController = Get.put(ChatItController());

  @override
  void onInit() {
    // jobPostId = Get.arguments;
  //    final args = Get.arguments as Map<String, dynamic>; // Cast arguments to a Map
  // jobPostId = args['jobPostId']; // Retrieve jobPostId
  // isMyJobPost = RxBool(args['isMyJobPost'] ?? false); // Initialize as `RxBool` 
  final args = Get.arguments as Map<String, dynamic>?; // Cast arguments to a Map, safely handle null
  jobPostId = args?['jobPostId']; // Retrieve jobPostId
  isMyJobPost = RxBool(args?['isMyJobPost'] ?? false); // Initialize as `RxBool` with a default value if null

    _getJobPostDetails();

    log(" position id: ${jobPostDetails.value.positionId?.id?.toLowerCase()}");
    super.onInit();
  }

// Conversion function: from ClientId to SocialUser
  SocialUser clientIdToSocialUser(ClientId clientId) {
    return SocialUser(
      id: clientId.id,
      name: clientId.name ?? clientId.restaurantName,
      positionId: clientId.positionId,
      positionName: clientId.positionName,
      email: clientId.email,
      role: clientId.role,
      profilePicture: clientId.profilePicture,
      countryName: clientId.countryName,
    );
  }

  Future<void> _getJobPostDetails() async {
    Either<CustomError, JobPostDetailsResponseModel> responseData =
        await _apiHelper.getJobPostDetails(jobPostId: jobPostId);
    jobPostDetailsDataLoading.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (response) async {
      if (response.status == "success" && response.details != null) {
        jobPostDetails.value = response.details!;
        jobPostDetails.refresh();
      } else {
        noDataFound.value = true;
      }
      jobPostDetailsDataLoading.value = false;
    });
  }

  //Client
  Future<void> onBookNowClick({required String employeeId}) async {
    if (!appController.hasPermission()) return;
    Get.toNamed(Routes.calender,
        arguments: [employeeId, shortListId(employeeId: employeeId), false]);
  }

  String shortListId({required String employeeId}) {
    for (var i in shortlistController.shortList) {
      if (i.employeeId == employeeId) {
        return i.sId ?? '';
      }
    }
    return '';
  }

  //Employee
  void onDetailsClick() {
    (jobPostDetails.value.dates ?? []).sort(
        (RequestDateModel a, RequestDateModel b) =>
            a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: reviseBookedDateList( bookedDateList: jobPostDetails.value.dates ?? []));
  }

  void calculatePreviousDates(
      {required List<RequestDateModel> bookedDateList}) {

        log("prev dates length: ${bookedDateList.length}");
    for (var i in bookedDateList) {
         DateTime? endDate = _parseEndDate(i.endDate);
       if (endDate != null) {
    
      if (endDate.toString().substring(0, 10) ==
          DateTime.now().toString().substring(0, 10)) {
        i.status = '';
      } else if (endDate.isBefore(DateTime.now())) {
        i.status = 'Done';
      } else {
        i.status = '';
      }
       }
    }
    
    Get.bottomSheet(
        JobDetailsMonthsWidget(requestDateList: bookedDateList));
  }

  void onJobPostDetailsClick() {
    // Sort dates based on startDate in ascending order
    (jobPostDetails.value.dates ?? []).sort(
        (RequestDateModel a, RequestDateModel b) =>
            a.startDate!.compareTo(b.startDate!));

    // Calculate the status for each date in the bookedDateList
    calculateBookedMonths(bookedDateList: (jobPostDetails.value.dates ?? []));
  }

  void calculateBookedMonths({required List<RequestDateModel> bookedDateList}) {
    for (var requestDate in bookedDateList) {
      // DateTime? endDate = DateTime.tryParse(requestDate.endDate ?? '');
      // DateTime now = DateTime.now();
   // Parse the startDate and endDate in "YYYY-MM" format
    DateTime now = DateTime.now();
    
    // Handle the case where startDate and endDate are in "YYYY-MM" format
    DateTime? startDate = _parseStartDate(requestDate.startDate);
    DateTime? endDate = _parseEndDate(requestDate.endDate);

      if (endDate != null) {
        if (endDate.toString().substring(0, 10) ==
            now.toString().substring(0, 10)) {
          requestDate.status = '';
        } else if (endDate.isBefore(now)) {
          requestDate.status = 'Done';
        } else {
          requestDate.status = '';
        }
      }
    }

    // Show bottom sheet with the hired history details
    Get.bottomSheet(
        EmployeeHiredHistoryDetailsWidget(requestDateList: bookedDateList));
  }
// Helper method to parse startDate (in "YYYY-MM" format)
DateTime? _parseStartDate(String? startDateStr) {
  if (startDateStr == null || startDateStr.isEmpty) return null;

  // Assuming the start date is at the beginning of the month (1st day)
  List<String> parts = startDateStr.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1); // Default to the 1st day of the month
}

// Helper method to parse endDate (in "YYYY-MM" format)
DateTime? _parseEndDate(String? endDateStr) {
  if (endDateStr == null || endDateStr.isEmpty) return null;

  // Assuming the end date is at the end of the month
  List<String> parts = endDateStr.split('-');
  DateTime parsedEndDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  // Calculate the last day of the month (next month, first day, minus one day)
  return parsedEndDate.add(Duration(days: DateTime(parsedEndDate.year, parsedEndDate.month + 1, 0).day - 1));
}
List<RequestDateModel> reviseBookedDateList({required List<RequestDateModel> bookedDateList}) {
  // Loop through each requestDate in the list
  for (var requestDate in bookedDateList) {
    // Parse and format the startDate and endDate properly
    DateTime? startDate = _parseStartDate(requestDate.startDate);
    DateTime? endDate = _parseEndDate(requestDate.endDate);

    // Only proceed if both startDate and endDate are valid
    if (startDate != null && endDate != null) {
      // Update the status based on the current date and the endDate
      DateTime now = DateTime.now();

      // Check if the task is done, active today, or pending
      if (endDate.toString().substring(0, 10) == now.toString().substring(0, 10)) {
        requestDate.status = ''; // Active today
      } else if (endDate.isBefore(now)) {
        requestDate.status = 'Done'; // Task is done
      } else {
        requestDate.status = ''; // Task still pending
      }

      // Update the startDate and endDate to the correct format
      requestDate.startDate = startDate.toString(); // Store the start date in a formatted string
      requestDate.endDate = endDate.toString(); // Store the end date in a formatted string
    }
  }

  // Return the updated list
  return bookedDateList;
}

  void showInterest({required BuildContext context}) async {
    CustomLoader.show(context);
    InterestedRequestModel interestedRequestModel = InterestedRequestModel(
        id: jobPostDetails.value.id ?? "",
        employeeId: appController.user.value.employee?.id ?? "");
    Either<CustomError, Response> responseData = await _apiHelper.interested(
        interestedRequestModel: interestedRequestModel);
    Get.back();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context, customError);
    }, (Response response) {
      if ([200, 201].contains(response.statusCode)) {
        Get.back();
        Utils.showSnackBar(
            message: MyStrings.thanksForShowingInterest.tr, isTrue: true);
      } else if ([400].contains(response.statusCode)) {
        var responseBody = jsonDecode(response.bodyString.toString());
        Utils.showSnackBar(message: responseBody['message'], isTrue: false);
      } else {
        Utils.showSnackBar(
            message: MyStrings.somethingWentWrong.tr, isTrue: false);
      }
    });
  }

  Future<void> chatWithEmployee(
          {required LiveChatDataTransferModel liveChatDataTransferModel}) async {

    isFetching.value = true;
    isFetchingId.value = liveChatDataTransferModel.toId;
    ConversationCreateRequestModel conversationCreateRequestModel = ConversationCreateRequestModel(
        senderId: liveChatDataTransferModel.senderId,
        receiverId: liveChatDataTransferModel.toId,
        isAdmin: false);

    _apiHelper
        .createConversationWithCandidate(
        conversationCreateRequestModel:conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        log("Error: ${customError.msg}");
      }, (ConversationResponseModel response) {
        if (response.status == "success" &&
            response.statusCode == 201 &&
            response.details != null) {
          log("great");
          log("cov id: ${response.details?.id ?? ""}");
          Get.toNamed(
              Routes.liveChat,
              arguments: LiveChatDataTransferModel(
                  id:response.details?.id,
                  role: liveChatDataTransferModel.role,
                  toName:liveChatDataTransferModel.toName ,
                  toId:liveChatDataTransferModel.toId,
                  toProfilePicture: liveChatDataTransferModel.toProfilePicture));
        }
      });
      isFetching.value = false;
    });
  }
  // Function to add dimensions to SVG if missing
  String addSvgDimensions(String htmlContent) {
    if (htmlContent.contains('<svg') && !htmlContent.contains('viewBox')) {
      // Add default width, height, and viewBox to SVG if missing
      htmlContent = htmlContent.replaceAll('<svg', '<svg width="100" height="100" viewBox="0 0 100 100"');
    }
    return htmlContent;
  }
  bool get showInterestedButton =>
      appController.user.value.isEmployee && !appController.user.value.isClient && !appController.user.value.isPremiumClient &&
      Utils.getPositionName("${appController.user.value.employee!.positionId}").toLowerCase() ==
          jobPostDetails.value.positionId?.name?.toLowerCase();
}
