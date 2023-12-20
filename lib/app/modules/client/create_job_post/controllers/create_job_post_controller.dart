import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/utils/type_def.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/timer_wheel_widget.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/custom_slider_model.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/custom_slider_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/job_calender_widget.dart';
import 'package:mh/app/repository/api_helper.dart';

class CreateJobPostController extends GetxController {
  BuildContext? context;
  final AppController appController = Get.find<AppController>();
  final ApiHelper _apiHelper = Get.find();

  Rx<CreateJobPostRequestModel> createJobPostRequestModel = CreateJobPostRequestModel().obs;
  Rx<CustomSliderModel> customSliderModel = CustomSliderModel().obs;
  Rx<TextEditingController> tecRatePerHour = TextEditingController().obs;
  RxList<String> nationalities = <String>[].obs;
  RxList<NationalityDetailsModel> nationalityList = <NationalityDetailsModel>[].obs;

  Rx<TextEditingController> tecExperience = TextEditingController().obs;
  Rx<TextEditingController> tecAge = TextEditingController().obs;
  TextEditingController tecDescription = TextEditingController();

  Rx<TextEditingController> tecPublishDate = TextEditingController().obs;
  Rx<TextEditingController> tecEndDate = TextEditingController().obs;
  Rx<TextEditingController> tecSelectedDates = TextEditingController().obs;
  RxList<RequestDateModel> requestDateList = <RequestDateModel>[].obs;

  final RxSet<DateTime> selectedDates = <DateTime>{}.obs;
  List<String> vacancyList = <String>[
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30"
  ];

  DateTime selectedDate = DateTime.now();

  final List<String> dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  late PageController pageController;
  RxInt currentPageIndex = 0.obs;
  Rx<DateTime> initialDate = DateTime.now().obs;
  Rx<DateTime?> rangeStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> rangeEndDate = Rx<DateTime?>(null);
  RxBool sameAsStartDate = false.obs;

  @override
  void onInit() {
    _getNationalityList();
    pageController = PageController(initialPage: currentPageIndex.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPositionChange(String? position) {
    createJobPostRequestModel.value.positionId = Utils.getPositionId(position ?? '');
    createJobPostRequestModel.refresh();
  }

  void onHourlyRateSubmitClick() {
    tecRatePerHour.value.text =
        "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${customSliderModel.value.minValue} - ${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${customSliderModel.value.maxValue}";
    createJobPostRequestModel.value.minRatePerHour = customSliderModel.value.minValue;
    createJobPostRequestModel.value.maxRatePerHour = customSliderModel.value.maxValue;
    createJobPostRequestModel.refresh();
    tecRatePerHour.refresh();
    Get.back();
  }

  void onSkillsChange(String? skill) {
    createJobPostRequestModel.value.skills?.add(skill ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(createJobPostRequestModel.value.skills ?? []);
    createJobPostRequestModel.value.skills = uniqueSet.toList();
    createJobPostRequestModel.refresh();
  }

  void onSkillClearClick({required int index}) {
    createJobPostRequestModel.value.skills?.removeAt(index);
    createJobPostRequestModel.refresh();
  }

  Future<void> _getNationalityList() async {
    Either<CustomError, NationalityModel> response = await _apiHelper.getNationalities();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (NationalityModel responseData) {
      if (responseData.status == "success") {
        nationalityList.value = responseData.nationalities ?? [];
      }
    });
  }

  void onNationalityChange(String? nationality) {
    nationalities.add(nationality ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(nationalities);
    nationalities.value = uniqueSet.toList();
    nationalities.refresh();
  }

  void onNationalityClearClick({required int index}) {
    nationalities.removeAt(index);
    nationalities.refresh();
  }

  void onLanguageChange(String? language) {
    createJobPostRequestModel.value.languages?.add(language ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(createJobPostRequestModel.value.languages ?? []);
    createJobPostRequestModel.value.languages = uniqueSet.toList();
    createJobPostRequestModel.refresh();
  }

  void onLanguageClearClick({required int index}) {
    createJobPostRequestModel.value.languages?.removeAt(index);
    createJobPostRequestModel.refresh();
  }

  void onCustomSliderClick(
      {required BuildContext context, required int minValue, required int maxValue, required Function() onTap}) {
    customSliderModel.value.minValue = minValue.toDouble();
    customSliderModel.value.maxValue = maxValue.toDouble();
    customSliderModel.value.onTap = onTap;
    customSliderModel.refresh();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
          // padding: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).viewInsets.bottom,
          // ),
          color: MyColors.lightCard(context),
          child: const CustomSliderWidget()),
    );
  }

  void onExperienceSubmitClick() {
    tecExperience.value.text = "${customSliderModel.value.minValue} - ${customSliderModel.value.maxValue} years";
    createJobPostRequestModel.value.minExperience = customSliderModel.value.minValue?.round();
    createJobPostRequestModel.value.maxExperience = customSliderModel.value.maxValue?.round();
    createJobPostRequestModel.refresh();
    tecExperience.refresh();
    Get.back();
  }

  void onAgeSubmitClick() {
    tecAge.value.text = "${customSliderModel.value.minValue} - ${customSliderModel.value.maxValue} years";
    createJobPostRequestModel.value.minAge = customSliderModel.value.minValue?.round();
    createJobPostRequestModel.value.maxAge = customSliderModel.value.maxValue?.round();
    createJobPostRequestModel.refresh();
    tecAge.refresh();
    Get.back();
  }

  void onVacancyChange(String? vac) {
    createJobPostRequestModel.value.vacancy = int.parse(vac ?? "");
    createJobPostRequestModel.refresh();
  }

  Future<void> selectDate({required BuildContext context, required String dateType}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (dateType == 'publish') {
        tecPublishDate.value.text = picked.dMMMy;
        createJobPostRequestModel.value.publishedDate = DateTime.parse(picked.toString().split(" ").first);
      } else {
        tecEndDate.value.text = picked.dMMMy;
        createJobPostRequestModel.value.endDate = DateTime.parse(picked.toString().split(" ").first);
      }
    }
    createJobPostRequestModel.refresh();
  }

  void onPageChanged(int index) {
    final DateTime now = DateTime.now();
    initialDate.value = DateTime(now.year, now.month + index, now.day);
    currentPageIndex.value = index;
  }

  void onSelectDaysClick() {
    Get.dialog(
        const Dialog(insetPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0), child: JobCalenderWidget()),
        barrierDismissible: false);
  }

  bool isDateInSelectedRange(DateTime currentDate, RequestDateModel dateRange) {
    if (dateRange.startDate != null && dateRange.endDate != null) {
      return currentDate.isAfter(DateTime.parse(dateRange.startDate!)) &&
          currentDate.isBefore((DateTime.parse(dateRange.endDate!)).add(const Duration(days: 1)));
    }
    return false;
  }

  void onDateClick({required DateTime currentDate}) {
    print('CreateJobPostController.onDateClick');
    if (rangeStartDate.value == null) {
      sameAsStartDate.value = false;
      rangeStartDate.value = currentDate;
    } else if (rangeStartDate.value != null && currentDate.isBefore(rangeStartDate.value!)) {
      rangeEndDate.value = rangeStartDate.value;
      rangeStartDate.value = currentDate;
    } else if (rangeEndDate.value == null) {
      rangeEndDate.value = currentDate;
    } else {}
    loadSelectedDates(currentDate: currentDate);
    loadRequestedDateList(currentDate: currentDate);
  }

  void loadSelectedDates({required DateTime currentDate}) {
    if (selectedDates.contains(currentDate)) {
      selectedDates.remove(currentDate);
    } else {
      selectedDates.add(currentDate);
      /*  if (totalDateList.anyDatesExistInRange(
          rangeStart: rangeStartDate.value.toString().substring(0, 10),
          rangeEnd: currentDate.toString().substring(0, 10)) ==
          false) {
        selectedDates.add(currentDate);
      }*/
    }
  }

  void loadRequestedDateList({required DateTime currentDate}) {
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
    print('CreateJobPostController.loadRequestedDateList: ${requestDateList.length}');
    requestDateList.refresh();
  }

  void onSameAsStartDatePressed(bool? value) {
    sameAsStartDate.value = !sameAsStartDate.value;
    if (sameAsStartDate.value == true) {
      rangeEndDate.value = rangeStartDate.value;
    } else {
      rangeEndDate.value = null;
    }

    loadRequestedDateList(currentDate: rangeStartDate.value!);
  }

  void onRemoveClickF({required int index}) {
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
                  _title(context, "From time"),
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
                  _title(context, "To time"),
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
                    text: "Done",
                    onTap: () {
                      if (requestDateList[index].startTime == requestDateList[index].endTime) {
                        CustomDialogue.information(
                          context: context,
                          title: "Invalid Time Range",
                          description: "From-time and To-time should be same",
                        );
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

  void onPostJobClick() async {
    CustomLoader.show(context!);

    createJobPostRequestModel.value.description = tecDescription.text;
    createJobPostRequestModel.value.dates = requestDateList;

    Either<CustomError, Response> response =
        await _apiHelper.createJobPost(createJobPostRequestModel: createJobPostRequestModel.value);
    Get.back();
    response.fold((l) {
      Logcat.msg(l.msg);
    }, (Response r) {
      print('CreateJobPostController.onPostJobClick: ${r.statusCode}');
      if ([200, 201].contains(r.statusCode) == true) {
        print('CreateJobPostController.onPostJobClick hey');
        Get.back();
        Utils.showSnackBar(message: "Job has been created successfully", isTrue: true);
      } else {
        Utils.showSnackBar(message: 'Job post creation failed', isTrue: false);
      }
    });
  }
}
