import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/logcat.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/single_booking_details_model.dart';
import 'package:mh/app/modules/employee_booked_history_details/models/rejected_date_request_model.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeBookedHistoryDetailsController extends GetxController {
  Rx<BookingDetailsModel> bookingDetails = BookingDetailsModel().obs;
  RxBool bookingDetailsDataLoading = true.obs;
  String notificationId = '';

  final ApiHelper _apiHelper = Get.find<ApiHelper>();

  BuildContext? context;

  @override
  void onInit() async {
    notificationId = Get.arguments;
    await _getBookingDetails();
    super.onInit();
  }

  Future<void> _getBookingDetails() async {
    bookingDetailsDataLoading.value = true;
    Either<CustomError, SingleBookingDetailsModel> responseData =
        await _apiHelper.getBookingDetails(notificationId: notificationId);
    bookingDetailsDataLoading.value = false;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _getBookingDetails);
    }, (SingleBookingDetailsModel response) {
      if (response.status == "success" && response.statusCode == 200 && response.bookingDetails != null) {
        bookingDetails.value = response.bookingDetails!;
      }
    });
  }

  Future<void> updateRequestDate({required RequestDateModel rejectedDate}) async {
    if (bookingDetails.value.requestDateList!.length > 1) {
      CustomDialogue.confirmation(
        context: Get.context!,
        title: "Confirm?",
        msg: "Are you sure you want to remove this range?",
        confirmButtonText: "Remove",
        onConfirm: () async {
          Get.back();
          CustomLoader.show(context!);
          List<RequestDateModel> rejectedDateList = <RequestDateModel>[];
          rejectedDateList.add(rejectedDate);
          bookingDetails.value.requestDateList?.removeWhere((element) => element == rejectedDate);
          RejectedDateRequestModel rejectedDateRequestModel = RejectedDateRequestModel(
              rejectedDateList: rejectedDateList,
              shortListId: notificationId,
              requestDateList: bookingDetails.value.requestDateList ?? []);

          Either<CustomError, Response> response =
              await _apiHelper.updateRequestDate(rejectedDateRequestModel: rejectedDateRequestModel);
          CustomLoader.hide(context!);
          response.fold((l) {
            Logcat.msg(l.msg);
          }, (Response r) {
            if ([200, 201].contains(r.statusCode) == true) {
              _getBookingDetails();
            } else {
              Utils.showSnackBar(message: 'You cannot delete any range of booking date right now', isTrue: false);
            }
          });
        },
      );
    } else {
      Utils.showSnackBar(message: 'You cannot delete when you have only one range of booking date', isTrue: false);
    }
  }
}
