import 'package:dartz/dartz.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';

class EmployeeDashboardController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();

  RxList<CheckInCheckOutHistoryElement> history = <CheckInCheckOutHistoryElement>[].obs;
  RxList<CheckInCheckOutHistoryElement> dateWiseHistoryList = <CheckInCheckOutHistoryElement>[].obs;
  Rx<DateTime> selectedStartDate = DateTime.now().obs;
  Rx<DateTime> selectedEndDate = DateTime.now().add(const Duration(days: 1)).obs;

  RxBool isInitial = true.obs;

  RxInt pageSize = 10.obs;
  RxInt currentPage = 1.obs;
  RxBool loading = true.obs;
  final isLoadingMoreData = false.obs;
  PageController pageController = PageController();
  RxBool stopScrolling = false.obs;
    // final AppController appController = Get.find();
    // UserProfileCompletionDetails? userProfileDetails;

  @override
  void onInit() async {
    // await getProfileCompletion(appController.user.value.userId);
    await _fetchCheckInOutHistory(page: currentPage.value, limit: pageSize.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
// Future<void>  getProfileCompletion(String userId) async{
//   final result= await _apiHelper.userProfileCompletionDetails(userId);

//   result.fold(
//     (error) {
//       // Handle the error case if needed
//       print("Error fetching profile completion details: $error");
//     },
//     (details) {
//       // Set the local variable with the result
//       userProfileDetails = details;
//       // Optionally, if using GetX or similar, update the state
//       update(); // or notifyListeners() if using Provider
//     },
//   );
// }
  Future<void> _fetchCheckInOutHistory({String? startDate, String? endDate, int? limit, int? page}) async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getEmployeeCheckInOutHistory(startDate: startDate, endDate: endDate, limit: limit, page: page);
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      history.value = checkInCheckOutHistory.checkInCheckOutHistory ?? [];
    });
  }

  void onDateRangePicked(DateTimeRange dateTime) async {
    selectedStartDate.value = dateTime.start;
    selectedEndDate.value = dateTime.end;
    isInitial.value = false;
    await _fetchCheckInOutHistory(
      startDate: dateTime.start.toString().split(" ").first,
      endDate: dateTime.end.toString().split(" ").first,
    );
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

  void loadMoreData() async {
    if (stopScrolling.value == false) {
      if (isLoadingMoreData.value==true ){
        return;
      }else {
      currentPage.value++;
      isLoadingMoreData(true);
      Either<CustomError, CheckInCheckOutHistory> response =
      await _apiHelper.getEmployeeCheckInOutHistory(
          limit: pageSize.value, page: currentPage.value);

      isLoadingMoreData(false);
      response.fold((CustomError customError) {
        Utils.errorDialog(
            context!, customError..onRetry = _fetchCheckInOutHistory);
      }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
        if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).isNotEmpty) {
          if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).length <
              pageSize.value) {
            stopScrolling.value = true;
          }
          history.addAll(checkInCheckOutHistory.checkInCheckOutHistory ?? []);
          history.refresh();
        } else {
          stopScrolling.value = true;
        }
      });
    }
  }
  }
}
