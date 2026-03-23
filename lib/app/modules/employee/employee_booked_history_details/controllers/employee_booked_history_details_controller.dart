import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/widgets/client_uniform_image_widget.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/employee/employee_booked_history_details/models/rejected_date_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/single_booking_details_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeBookedHistoryDetailsController extends GetxController {
  Rx<BookingDetailsModel> bookingDetails = BookingDetailsModel().obs;
  RxBool bookingDetailsDataLoading = true.obs;
  String notificationId = '';

  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  final AppController _appController = Get.find<AppController>();

  BuildContext? context;
  Rx<PositionInfoDetailsModel> positionInfo = PositionInfoDetailsModel().obs;
  RxBool uniformImageDataLoaded = false.obs;

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
        title: MyStrings.confirm.tr,
        msg: MyStrings.removeThisRange.tr,
        confirmButtonText: MyStrings.remove.tr,
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
              Utils.showSnackBar(message: MyStrings.youCannotDeleteAnyRangeOfBookingDateRightNow.tr, isTrue: false);
            }
          });
        },
      );
    } else {
      Utils.showSnackBar(message: MyStrings.youCannotDeleteWhenYouHaveOnlyOneRangeOfBookingDate.tr, isTrue: false);
    }
  }

  void onViewUniformClick() async {
    Either<CustomError, PositionInfoModel> responseData =
        await _apiHelper.getPositionInfo(positionId: _appController.user.value.employee?.positionId ?? '');
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (response) {
      if (response.status == "success" && response.statusCode == 200 && response.details != null) {
        positionInfo.value = response.details!;
        positionInfo.refresh();
      }
      uniformImageDataLoaded.value = true;
    });

    Get.dialog(Dialog(
      backgroundColor: MyColors.lightCard(Get.context!),
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: ClientUniformImageWidget(positionInfoDetailsModel: positionInfo.value),
    ));
  }
}
