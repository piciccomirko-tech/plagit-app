import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/logcat.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/timer_wheel_widget.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/calender/models/calender_model.dart';
import 'package:mh/app/modules/calender/models/update_unavailable_date_request_model.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/update_shortlist_request_model.dart';
import 'package:mh/app/modules/client/common/shortlist_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class CalenderController extends GetxController {
  BuildContext? context;
  String employeeId = '';
  String shortListId = '';

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  Rx<DateListModel> dateListModel = DateListModel().obs;
  List<CalenderDataModel> totalDateList = <CalenderDataModel>[];
  RxBool dateDataLoading = true.obs;

  final List<String> dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  late PageController pageController;
  RxInt currentPageIndex = 0.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  final RxSet<DateTime> selectedDates = <DateTime>{}.obs;
  Rx<DateTime?> rangeStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> rangeEndDate = Rx<DateTime?>(null);

  //For employee only
  RxList<Dates> unavailableDateList = <Dates>[].obs;
  RxBool sameAsStartDate = false.obs;

  //For client only
  RxList<RequestDateModel> requestDateList = <RequestDateModel>[].obs;
  final ShortlistController shortlistController = Get.find();

  bool? uniformMandatory;

  @override
  void onInit() {
    employeeId = Get.arguments[0];
    shortListId = Get.arguments[1] ?? '';
    uniformMandatory = Get.arguments[2];
    _getCalenderData();
    pageController = PageController(initialPage: currentPageIndex.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onDateClick({required DateTime currentDate}) {
    if (Get.isRegistered<ClientHomeController>() == true) {
      onDateClickForShortList(currentDate: currentDate);
    } else if (Get.isRegistered<EmployeeHomeController>() == true) {
      onDateClickForEmployee(currentDate: currentDate);
    } else {
      Utils.showSnackBar(message: 'You cannot update any date', isTrue: false);
    }
  }

  void _getCalenderData() {
    dateDataLoading.value = true;
    _apiHelper.getCalenderData(employeeId: employeeId).then((Either<CustomError, CalenderModel> responseData) {
      dateDataLoading.value = false;
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getCalenderData);
      }, (CalenderModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.dateList != null) {
          dateListModel.value = response.dateList!;
          dateListModel.refresh();
          loadTotalDateList();
        }
      });
    });
  }

  void loadTotalDateList() {
    totalDateList = <CalenderDataModel>[
      ...dateListModel.value.unavailableDates ?? [],
      ...dateListModel.value.pendingDates ?? [],
      ...dateListModel.value.bookedDates ?? [],
    ];
  }

  void onPageChanged(int index) {
    final DateTime now = DateTime.now();
    selectedDate.value = DateTime(now.year, now.month + index, now.day);
    currentPageIndex.value = index;
    //selectedDate.value = DateTime.now().add(Duration(days: index * 30));
  }

  ///---------------- For employee only -------------------

  //For employee only
  void onDateClickForEmployee({required DateTime currentDate}) {
    if (currentDate.isBefore(DateTime.now()) || selectedDate.value == currentDate) {
      return; // Skip processing for previous dates and current date
    }

    if (selectedDates.length == 2 || (rangeStartDate.value != null && rangeEndDate.value != null)) {
      selectedDates.clear();
      rangeStartDate.value = currentDate;
      rangeEndDate.value = null;
      sameAsStartDate.value = false;
    } else if (rangeStartDate.value == null) {
      rangeStartDate.value = currentDate;
    } else if (totalDateList.anyDatesExistInRange(
            rangeStart: rangeStartDate.value.toString().substring(0, 10),
            rangeEnd: currentDate.toString().substring(0, 10)) ==
        true) {
      Utils.showSnackBar(message: 'You cannot select this range', isTrue: false);
    } else if (rangeStartDate.value != null && currentDate.isBefore(rangeStartDate.value!)) {
      rangeEndDate.value = rangeStartDate.value;
      rangeStartDate.value = currentDate;
    } else if (rangeEndDate.value == null && currentDate != rangeStartDate.value) {
      rangeEndDate.value = currentDate;
    } else {
      rangeEndDate.value = null;
      rangeStartDate.value = null;
      sameAsStartDate.value = false;
    }

    loadSelectedDates(currentDate: currentDate);
    loadUnavailableDates();
  }

  //For employees only
  void updateUnavailableDates() {
    CustomLoader.show(context!);

    UpdateUnavailableDateRequestModel updateUnavailableDateRequestModel =
        UpdateUnavailableDateRequestModel(unavailableDateList: unavailableDateList.toSet().toList());
    _apiHelper
        .updateUnavailableDate(updateUnavailableDateRequestModel: updateUnavailableDateRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getCalenderData);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 200) {
          _getCalenderData();
          unavailableDateList.clear();
          selectedDates.clear();
          Get.back();
          Utils.showSnackBar(message: 'Dates have been updated successfully', isTrue: true);
        } else {
          Utils.showSnackBar(message: 'Date update failed', isTrue: false);
        }
      });
    });
  }

  //For employees only
  void loadUnavailableDates() {
    if (rangeStartDate.value != null && rangeEndDate.value != null) {
      unavailableDateList.add(Dates(
          startDate: rangeStartDate.value.toString().substring(0, 10),
          endDate: rangeEndDate.value.toString().substring(0, 10)));
    }

    if (dateListModel.value.unavailableDates != null && dateListModel.value.unavailableDates!.isNotEmpty) {
      for (CalenderDataModel date in dateListModel.value.unavailableDates!) {
        unavailableDateList.add(Dates(startDate: date.startDate ?? '', endDate: date.endDate ?? ''));
      }
    }
  }

  //For employee only
  void onSameAsStartDatePressedForEmployee(bool? value) {
    sameAsStartDate.value = !sameAsStartDate.value;
    if (sameAsStartDate.value == true) {
      rangeEndDate.value = rangeStartDate.value;
    } else {
      rangeEndDate.value = null;
    }
    loadUnavailableDates();
  }

  //For employee only
  void onRemoveClick() {
    selectedDates.clear();
    rangeStartDate.value = null;
    rangeEndDate.value = null;
    sameAsStartDate.value = false;
  }

  //For employee only
  bool get disableSubmitButton {
    return rangeStartDate.value == null || rangeEndDate.value == null;
  }

  //For employee only
  void loadSelectedDates({required DateTime currentDate}) {
    if (selectedDates.contains(currentDate)) {
      selectedDates.remove(currentDate);
    } else {
      if (totalDateList.anyDatesExistInRange(
              rangeStart: rangeStartDate.value.toString().substring(0, 10),
              rangeEnd: currentDate.toString().substring(0, 10)) ==
          false) {
        selectedDates.add(currentDate);
      }
    }
  }

  //For employee only
  int get totalSelectedDaysForEmployee {
    if (rangeStartDate.value == null || rangeEndDate.value == null) {
      return 0;
    } else {
      return rangeStartDate.value!.daysUntil(rangeEndDate.value!);
    }
  }

  bool isDateInSelectedRangeForEmployee(DateTime currentDate) {
    if (rangeStartDate.value != null && rangeEndDate.value != null) {
      return currentDate.isAfter(rangeStartDate.value!) &&
          currentDate.isBefore(rangeEndDate.value!.add(const Duration(days: 1)));
    }
    return false;
  }

  void onEmployeeUnavailableDateUpdate({required DateTime currentDate}) {
    if (!Get.isRegistered<EmployeeHomeController>()) return;
    CustomDialogue.confirmation(
      context: context!,
      title: "Warning!",
      msg: "Are you sure you want to make this date range available?",
      confirmButtonText: "YES",
      onConfirm: () async {
        unavailableDateList.clear();
        Get.back();
        final String dateToRemove = currentDate.toString().substring(0, 10);
        dateListModel.value.unavailableDates?.removeWhere(
            (item) => item.startDate!.compareTo(dateToRemove) <= 0 && item.endDate!.compareTo(dateToRemove) >= 0);
        for (CalenderDataModel date in dateListModel.value.unavailableDates!) {
          if (!unavailableDateList.contains(Dates(startDate: date.startDate ?? '', endDate: date.endDate ?? ''))) {
            unavailableDateList.add(Dates(startDate: date.startDate ?? '', endDate: date.endDate ?? ''));
          }
        }
        updateUnavailableDates();
      },
    );
  }

  ///-------------------------------------------------------------------

  ///---------------- For Client only ----------------------------------

  void onDateClickForShortList({required DateTime currentDate}) {
    if (selectedDates.contains(currentDate) == true ||
        requestDateList.any((dateRange) => isDateInSelectedRangeForShortList(currentDate, dateRange)) == true) {
      return; // Skip processing for previous dates and current date
    }

    if (rangeStartDate.value == null) {
      sameAsStartDate.value = false;
      rangeStartDate.value = currentDate;
    } else if (inValidRange(currentDate: currentDate) == true) {
      Utils.showSnackBar(message: 'You cannot select this range', isTrue: false);
    } else if (rangeStartDate.value != null && currentDate.isBefore(rangeStartDate.value!)) {
      rangeEndDate.value = rangeStartDate.value;
      rangeStartDate.value = currentDate;
    } else if (rangeEndDate.value == null) {
      rangeEndDate.value = currentDate;
    } else {}

    //totalDateList.clear();
    loadSelectedDates(currentDate: currentDate);
    loadRequestedDateList(currentDate: currentDate);
  }

  void loadRequestedDateList({required DateTime currentDate}) {
    if (inValidRange(currentDate: currentDate) == false) {
      if (rangeStartDate.value != null && rangeEndDate.value == null) {
        requestDateList.insert(
            0,
            RequestDateModel(
              startDate: rangeStartDate.value.toString().substring(0, 10),
            ));
      } else if (rangeEndDate.value != null && rangeStartDate.value != null) {
        requestDateList.removeWhere(
            (RequestDateModel element) => element.startDate == rangeStartDate.value.toString().substring(0, 10));
        requestDateList.removeWhere(
            (RequestDateModel element) => element.startDate == rangeEndDate.value.toString().substring(0, 10));
        requestDateList.insert(
            0,
            RequestDateModel(
              startDate: rangeStartDate.value.toString().substring(0, 10),
              endDate: rangeEndDate.value.toString().substring(0, 10),
            ));

        rangeStartDate.value = null;
        rangeEndDate.value = null;
      }
      requestDateList.refresh();
    }
  }

  void onRemoveClickForShortList({required int index}) {
    if (requestDateList[index].startDate != null) {
      selectedDates.remove(DateTime.parse(requestDateList[index].startDate ?? ''));
    }
    if (requestDateList[index].endDate != null) {
      selectedDates.remove(DateTime.parse(requestDateList[index].endDate ?? ''));
    }

    selectedDates.refresh();
    requestDateList.removeAt(index);
    requestDateList.refresh();
    sameAsStartDate.value = false;
    rangeStartDate.value = null;
  }

  bool inValidRange({required DateTime currentDate}) {
    return totalDateList.anyDatesExistInRange(
        rangeStart: rangeStartDate.value.toString().substring(0, 10),
        rangeEnd: currentDate.toString().substring(0, 10));
  }

  void onSameAsStartDatePressedForShortList(bool? value) {
    sameAsStartDate.value = !sameAsStartDate.value;
    if (sameAsStartDate.value == true) {
      rangeEndDate.value = rangeStartDate.value;
    } else {
      rangeEndDate.value = null;
    }

    loadRequestedDateList(currentDate: rangeStartDate.value!);
  }

  bool isDateInSelectedRangeForShortList(DateTime currentDate, RequestDateModel dateRange) {
    if (dateRange.startDate != null && dateRange.endDate != null) {
      return currentDate.isAfter(DateTime.parse(dateRange.startDate!)) &&
          currentDate.isBefore((DateTime.parse(dateRange.endDate!)).add(const Duration(days: 1)));
    }
    return false;
  }

  void showTimePickerBottomSheet({required int index}) {
    requestDateList[index].startTime = Utils.getCurrentTimeWithAMPM();
    requestDateList[index].endTime = Utils.getCurrentTimeWithAMPM();

    showModalBottomSheet(
      context: context!,
      builder: (BuildContext context) {
        return Container(
          color: MyColors.lightCard(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 19.h),
                  Center(
                    child: Container(
                      height: 4.h,
                      width: 80.w,
                      decoration: const BoxDecoration(
                        color: MyColors.c_5C5C5C,
                      ),
                    ),
                  ),
                  SizedBox(height: 19.h),
                  _title(context, MyStrings.fromTime.tr),
                  TimerWheelWidget(
                    height: 150.h,
                    width: 300.w,
                    centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                    onTimeChanged: (String time) {
                      requestDateList[index].startTime = time;
                      requestDateList.refresh();
                    },
                  ),
                  SizedBox(height: 30.h),
                  _title(context, MyStrings.toTime.tr),
                  SizedBox(height: 11.h),
                  TimerWheelWidget(
                    height: 150.h,
                    width: 300.w,
                    centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                    onTimeChanged: (String time) {
                      requestDateList[index].endTime = time;
                      requestDateList.refresh();
                    },
                  ),
                  SizedBox(height: 30.h),
                  CustomButtons.button(
                    text: MyStrings.done.tr,
                    onTap: () {
                      if (requestDateList[index].startTime == requestDateList[index].endTime) {
                        CustomDialogue.information(
                            context: context,
                            title: MyStrings.invalidTimeRange.tr,
                            description: MyStrings.fromTimeToTime.tr);
                      } else {
                        Get.back(); // hide modal
                      }
                    },
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      // call after close modal
    });
  }

  static Widget _title(BuildContext context, String text) => Row(
        children: [
          _divider(context),
          SizedBox(width: 10.w),
          Text(
            text,
            style: MyColors.l7B7B7B_dtext(context).semiBold16,
          ),
          SizedBox(width: 10.w),
          _divider(context),
        ],
      );
  static Widget _divider(BuildContext context) => Expanded(
        child: Container(
          height: 1,
          color: MyColors.lD9D9D9_dstock(context),
        ),
      );

  bool get disabledBookButton {
    return requestDateList.hasNullAttributes();
  }

  void onBookNowClick() async {
    if (shortListId.isNotEmpty) {
      UpdateShortListRequestModel updateShortListRequestModel = UpdateShortListRequestModel(
          shortListId: shortListId, requestDateList: requestDateList, uniformMandatory: uniformMandatory);
      await _updateShortListDateOrTime(updateShortListRequestModel: updateShortListRequestModel);
    } else {
      await shortlistController.onBookNowClick(
          employeeId: employeeId, requestDateList: requestDateList, uniformMandatory: uniformMandatory);
    }
    Get.offNamed(Routes.clientShortlisted);
  }

  Future<void> _updateShortListDateOrTime({required UpdateShortListRequestModel updateShortListRequestModel}) async {
    CustomLoader.show(context!);
    Either<CustomError, Response> response =
        await _apiHelper.updateShortlistItem(updateShortListRequestModel: updateShortListRequestModel);
    CustomLoader.hide(context!);
    response.fold((l) {
      Logcat.msg(l.msg);
    }, (r) async {
      if ([200, 201].contains(r.statusCode)) {
        await shortlistController.fetchShortListEmployees();
      } else {
        CustomDialogue.information(
          context: Get.context!,
          title: "Error",
          description: "Something went wrong",
        );
      }
    });
  }
}
