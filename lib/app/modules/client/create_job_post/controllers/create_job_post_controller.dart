import 'dart:collection';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/timer_wheel_widget.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/slider_controller.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/custom_slider_model.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/job_calender_widget.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:html/dom.dart' as dom;

import '../../../../helpers/responsive_helper.dart';
import '../../../../routes/app_pages.dart';

class CreateJobPostController extends GetxController {
  BuildContext? context;
  final AppController appController = Get.find<AppController>();
  final SliderController sliderController = Get.put(SliderController());

  final ApiHelper _apiHelper = Get.find();
// Rx<CreateJobPostRequestModel> originalCreateJobPostRequestModel = CreateJobPostRequestModel().obs;

  Rx<CreateJobPostRequestModel> createJobPostRequestModel =
      CreateJobPostRequestModel().obs;
  Rx<CustomSliderModel> customSliderModel = CustomSliderModel().obs;
  RxList<String> skillList = <String>[].obs;
  RxList<String> nationalityList = <String>[].obs;
  RxList<String> languageList = <String>[].obs;
  Rx<String> selectedPositionName = 'Manager'.obs;
  Rx<TextEditingController> tecRatePerHour = TextEditingController().obs;
  RxList<NationalityDetailsModel> nationalities =
      <NationalityDetailsModel>[].obs;

  Rx<TextEditingController> tecExperience = TextEditingController().obs;
  Rx<TextEditingController> tecAge = TextEditingController().obs;
  Rx<TextEditingController> tecDescription = TextEditingController().obs;

  Rx<TextEditingController> tecPublishDate = TextEditingController().obs;
  Rx<TextEditingController> tecEndDate = TextEditingController().obs;
  Rx<TextEditingController> tecSelectedDates = TextEditingController().obs;
  RxList<RequestDateModel> requestDateList = <RequestDateModel>[].obs;

  //new text input instead of slider

  TextEditingController salaryAmount = TextEditingController();
  TextEditingController ageAmount = TextEditingController();
  TextEditingController experienceAmount = TextEditingController();

  final RxSet<DateTime> selectedDates = <DateTime>{}.obs;
  List<String> vacancyList =
      List<String>.generate(200, (index) => (index + 1).toString());

  Rx<String> selectedVacancy = "2".obs;

  DateTime selectedDate = DateTime.now();

  final List<String> dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  late PageController pageController;
  RxInt currentPageIndex = 0.obs;
  Rx<DateTime> initialDate = DateTime.now().obs;
  Rx<DateTime?> rangeStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> rangeEndDate = Rx<DateTime?>(null);
  RxBool sameAsStartDate = false.obs;
  String type = "create";
  // List of available months (next 12 months from the current month)
  RxList<DateTime> availableMonths = <DateTime>[].obs;

  // List of selected months
  RxList<DateTime> selectedMonths = <DateTime>[].obs;

  RxBool isJobPostCreateButtonShown= true.obs;
  @override
  void onInit() {
    // Generate the list of months when the controller is initialized
    availableMonths.value = _generateMonthsForNextYear();
    //  _initializeBackupModel();
    log("initiall dataaaaaaa");
    _loadUpdateData();
    _getNationalityList();
    pageController = PageController(initialPage: currentPageIndex.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Generate a list of months starting from the current month to the next 12 months
  List<DateTime> _generateMonthsForNextYear() {
    DateTime now = DateTime.now();
    List<DateTime> monthsList = [];
    for (int i = 0; i < 12; i++) {
      // Add each month starting from the current month
      monthsList.add(DateTime(now.year, now.month + i, 1));
    }
    return monthsList;
  }

  // Toggle the selection state of a given month
  void toggleMonthSelection(DateTime month) {
    if (selectedMonths.contains(month)) {
      selectedMonths
          .remove(month); // If the month is already selected, remove it
    } else {
      selectedMonths.add(month); // Otherwise, add it to the selected list
    }
  }

// Function to format the DateTime to 'YYYY-MM-DD'
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

// Prepare request date list using your existing model
  List<RequestDateModel> prepareRequestDateList() {
    return selectedMonths.map((month) {
      DateTime startDate =
          DateTime(month.year, month.month, 1); // Start of the month
      DateTime endDate =
          DateTime(month.year, month.month + 1, 0); // End of the month

      return RequestDateModel(
        startDate: formatDate(startDate),
        endDate: formatDate(endDate),
      );
    }).toList();
  }

// Function to parse the RequestDateModel list to RxList<DateTime>
  RxList<DateTime> convertRequestDateListToSelectedMonths(
      List<RequestDateModel> requestDateList) {
    RxList<DateTime> selectedMonths = <DateTime>[].obs;

    for (var requestDate in requestDateList) {
      if (requestDate.startDate != null) {
        String dateStr = requestDate.startDate!;

        // Remove unwanted characters if any
        dateStr = dateStr.replaceAll(RegExp(r'[^0-9-]'), '');

        // Check if date is in "yyyy-MM" format and append "-01" if needed
        if (RegExp(r'^\d{4}-\d{2}$').hasMatch(dateStr)) {
          dateStr += "-01";
        } else if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
          // If the date is not in "yyyy-MM" or "yyyy-MM-dd" format, skip it
          log("Invalid date format: $dateStr");
          continue;
        }

        try {
          DateTime parsedDate = DateTime.parse(dateStr);
          selectedMonths.add(parsedDate);
          log("Parsed date: $parsedDate");
        } catch (e) {
          log("Failed to parse date: $dateStr, error: $e");
        }
      }
    }

    return selectedMonths;
  }

  void onPositionChange(String? position) {
    selectedPositionName.value = position ?? "";
    createJobPostRequestModel.value.positionId =
        Utils.getPositionId(selectedPositionName.value);
    createJobPostRequestModel.refresh();
  }

  void onSkillsChange(String? skill) {
    skillList.add(skill ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(skillList);
    skillList.value = uniqueSet.toList();
    skillList.refresh();
  }

  void onSkillClearClick({required int index}) {
    skillList.removeAt(index);
    skillList.refresh();
  }

  Future<void> _getNationalityList() async {
    Either<CustomError, NationalityModel> response =
        await _apiHelper.getNationalities();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (NationalityModel responseData) {
      if (responseData.status == "success") {
        nationalities.value = responseData.nationalities ?? [];
      }
    });
  }

  void onNationalityChange(String? nationality) {
    nationalityList.add(nationality ?? "");
    LinkedHashSet<String> uniqueSet =
        LinkedHashSet<String>.from((nationalityList));
    nationalityList.value = uniqueSet.toList();
    nationalityList.refresh();
  }

  void onNationalityClearClick({required int index}) {
    nationalityList.removeAt(index);
    nationalityList.refresh();
  }

  void onLanguageChange(String? language) {
    languageList.add(language ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(languageList);
    languageList.value = uniqueSet.toList();
    languageList.refresh();
  }

  void onLanguageClearClick({required int index}) {
    languageList.removeAt(index);
    languageList.refresh();
  }

  void onCustomSliderClick(
      {required BuildContext context,
      required String minValue,
      required String maxValue,
      required Function() onTap,
      required String typeName}) {
    // Lazily initialize SliderController if it's not already registered
    // Lazily initialize SliderController if it's not already registered
    Get.lazyPut(() => SliderController());
    customSliderModel.value.minValue = minValue;
    customSliderModel.value.maxValue = maxValue;
    customSliderModel.value.onTap = onTap;
    customSliderModel.value.typeName = typeName;
    customSliderModel.refresh();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
          // padding: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).viewInsets.bottom,
          // ),
          color: MyColors.lightCard(context),
          child: Text("")
          //  CustomSliderWidget(
          //   type: typeName,
          // )
          
          ),
    );
  }

  void onHourlyRateSubmitClick() {
    // Get the selected min and max values from SliderController for the 'Hourly Rate' type
    final sliderData =
        Get.find<SliderController>().getSliderDataByType('Hourly Rate');

    if (sliderData != null) {
      // Update the hourly rate text field to show the selected range with currency symbols
      tecRatePerHour.value.text =
          "${Utils.getCurrencySymbol()}${sliderData['min']} - ${Utils.getCurrencySymbol()}${sliderData['max']}";

      // Save the selected hourly rate range in the job post request model
      createJobPostRequestModel.value.minRatePerHour = sliderData['min'];
      createJobPostRequestModel.value.maxRatePerHour = sliderData['max'];
      // Refresh to reflect the changes
      createJobPostRequestModel.refresh();
      tecRatePerHour.refresh();

      // Close the slider modal
      Get.back();
    }
  }

  void onExperienceSubmitClick() {
    // Get the selected min and max values from SliderController for the 'Experience' type
    final sliderData =
        Get.find<SliderController>().getSliderDataByType('Experience');

    if (sliderData != null) {
      // Update the experience text field to show the selected range
      tecExperience.value.text =
          "${sliderData['min']} - ${sliderData['max']} years";

      // Save the selected experience range in the job post request model
      createJobPostRequestModel.value.minExperience = sliderData['min'].round();
      createJobPostRequestModel.value.maxExperience = sliderData['max'].round();
      // Refresh to reflect the changes
      createJobPostRequestModel.refresh();
      tecExperience.refresh();

      // Close the slider modal
      Get.back();
    }
  }

  void onAgeSubmitClick() {
    // Get the selected min and max values from SliderController for the 'Age' type
    final sliderData = Get.find<SliderController>().getSliderDataByType('Age');

    if (sliderData != null) {
      // Update the age text field to show the selected range
      tecAge.value.text = "${sliderData['min']} - ${sliderData['max']} years";

      // Save the selected age range in the job post request model
      createJobPostRequestModel.value.minAge = sliderData['min'].round();
      createJobPostRequestModel.value.maxAge = sliderData['max'].round();
      // Refresh to reflect the changes
      createJobPostRequestModel.refresh();
      tecAge.refresh();

      // Close the slider modal
      Get.back();
    }
  }

  void onVacancyChange(String? vac) {
    selectedVacancy.value = vac ?? "";
    createJobPostRequestModel.value.vacancy = int.parse(vac ?? "");
    createJobPostRequestModel.refresh();
  }

  Future<void> selectDate(
      {required BuildContext context, required String dateType}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateType == "publish"
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 0)),
      firstDate: dateType == "publish"
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 0)),
      lastDate: DateTime(2101),
      helpText: dateType == "publish"
          ? ("${MyStrings.select.tr} ${MyStrings.publishDate.tr}").toUpperCase()
          : MyStrings.selectEndDate.tr.toUpperCase(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            textTheme: TextTheme(
              headlineMedium: TextStyle(fontSize: 24, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika,),
              labelLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.w500),
              headlineLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.w500),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (dateType == 'publish') {
        tecPublishDate.value.text = picked.dMMMy;
        createJobPostRequestModel.value.publishedDate =
            DateTime.parse(picked.toString().split(" ").first);
      } else {
        tecEndDate.value.text = picked.toString().split(" ").first;
        createJobPostRequestModel.value.endDate =
            DateTime.parse(picked.toString().split(" ").first);
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
        const Dialog(
            insetPadding:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
            child: JobCalenderWidget()),
        barrierDismissible: false);
  }

  bool isDateInSelectedRange(DateTime currentDate, RequestDateModel dateRange) {
    if (dateRange.startDate != null && dateRange.endDate != null) {
      return currentDate.isAfter(DateTime.parse(dateRange.startDate!)) &&
          currentDate.isBefore((DateTime.parse(dateRange.endDate!))
              .add(const Duration(days: 1)));
    }
    return false;
  }

  void onDateClick({required DateTime currentDate}) {
    if (rangeStartDate.value == null) {
      sameAsStartDate.value = false;
      rangeStartDate.value = currentDate;
    } else if (rangeStartDate.value != null &&
        currentDate.isBefore(rangeStartDate.value!)) {
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
      requestDateList.removeWhere((RequestDateModel element) =>
          element.startDate ==
          rangeStartDate.value.toString().substring(0, 10));
      requestDateList.removeWhere((RequestDateModel element) =>
          element.startDate == rangeEndDate.value.toString().substring(0, 10));
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
      selectedDates
          .remove(DateTime.parse(requestDateList[index].startDate ?? ''));
    }
    if (requestDateList[index].endDate != null) {
      selectedDates
          .remove(DateTime.parse(requestDateList[index].endDate ?? ''));
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
                      if (requestDateList[index].startTime ==
                          requestDateList[index].endTime) {
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

  void onDateSubmitClick() {
    tecSelectedDates.value.text =
        "${requestDateList.calculateTotalDays()} days selected";
    Get.back();
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
  
    // if (salaryAmount.text.isEmpty) {
    //   Utils.showSnackBar(
    //       message: "Hourly Rate range is required", isTrue: false);
    // }
    //  else
      if (skillList.isEmpty) {
      Utils.showSnackBar(message: "Skills are required", isTrue: false);
    }
    // else if (tecSelectedDates.value.text.isEmpty) {
    //   Utils.showSnackBar(message: "Dates are required ", isTrue: false);
    // }
    else if (nationalityList.isEmpty) {
      Utils.showSnackBar(message: "Nationalities are required ", isTrue: false);
    } 
    // else if (experienceAmount.text.isEmpty) {
    //   Utils.showSnackBar(
    //       message: "Experience range is required ", isTrue: false);
    // } 
        else if (selectedMonths.isEmpty) {
      Utils.showSnackBar(message: "Month are required ", isTrue: false);
    }
    else if (languageList.isEmpty) {
      Utils.showSnackBar(message: "Languages are required ", isTrue: false);
    }
    // else if (ageAmount.text.isEmpty) {
    //   Utils.showSnackBar(message: "Age range is required ", isTrue: false);
    // }
     else if (tecPublishDate.value.text.isEmpty) {
      Utils.showSnackBar(message: "Publish date is required ", isTrue: false);
    } else if (tecEndDate.value.text.isEmpty) {
      Utils.showSnackBar(message: "End date is required ", isTrue: false);
    }
    //  else if (tecDescription.value.text.isEmpty) {
    //   Utils.showSnackBar(message: "Description is required ", isTrue: false);
    // }
     else {
      CustomLoader.show(context!);
  isJobPostCreateButtonShown.value= false;
      createJobPostRequestModel.value.vacancy =
          int.parse(selectedVacancy.value);
      createJobPostRequestModel.value.positionId =
          Utils.getPositionId(selectedPositionName.value);
      createJobPostRequestModel.value.clientId =
          appController.user.value.client?.id;
      createJobPostRequestModel.value.description = tecDescription.value.text;
      // createJobPostRequestModel.value.dates = requestDateList;
      createJobPostRequestModel.value.dates = prepareRequestDateList();
      createJobPostRequestModel.value.skills = skillList;
      createJobPostRequestModel.value.nationalities = nationalityList;
      createJobPostRequestModel.value.languages = languageList;

      // new text filed data instead of sliders

      // createJobPostRequestModel.value.minAge = ageAmount.text;
      // createJobPostRequestModel.value.maxAge = ageAmount.text;
      // createJobPostRequestModel.value.minRatePerHour =
      //     salaryAmount.text;
      // createJobPostRequestModel.value.maxRatePerHour =
      //    salaryAmount.text;
      // createJobPostRequestModel.value.minExperience =
      //   experienceAmount.text;
      // createJobPostRequestModel.value.maxExperience =
      //    experienceAmount.text;
        createJobPostRequestModel.value.minRatePerHour= null;
        createJobPostRequestModel.value.maxRatePerHour= null;
        createJobPostRequestModel.value.minExperience= null;
        createJobPostRequestModel.value.maxExperience= null;
        createJobPostRequestModel.value.minAge= null;
        createJobPostRequestModel.value.maxAge= null;
    createJobPostRequestModel.value.salary =
         salaryAmount.text;
      createJobPostRequestModel.value.experience =
        experienceAmount.text;
      createJobPostRequestModel.value.age =
         ageAmount.text;
isJobPostCreateButtonShown.value= false;
      log("job payload: ${createJobPostRequestModel.value.toJson(type: type)}");

      Either<CustomError, CommonResponseModel> response =
          await _apiHelper.createJobPost(
              createJobPostRequestModel: createJobPostRequestModel.value);
      // log("response: ${response.asLeft.msg}");
      Get.back();
      response.fold((l) {
        Logcat.msg(l.msg);
      }, (CommonResponseModel r) {
        if ([200, 201].contains(r.statusCode) == true &&
            r.status == "success") {
              isJobPostCreateButtonShown.value= false;
          Get.find<ClientHomePremiumController>().getMyJobPosts();
          Get.find<ClientHomePremiumController>().getJobPosts();
          Get.find<ClientPremiumRootController>().showExpandable.value = false;
          Get.find<ClientHomePremiumController>().selectedTabIndex.value = 2;
          Get.find<ClientHomePremiumController>().selectTab(2);
          Get.back();
          CustomDialogue.confirmation(
            context: Get.context!,
            title: MyStrings.success.tr,
            msg: MyStrings.jobOfferPosted.tr,
            confirmButtonText: MyStrings.ok.tr,
            onConfirm: () async {
              Get.back();
              isJobPostCreateButtonShown.value= false;
            },
          );
        }
        else if([400].contains(r.statusCode) == true && r.message.toString().toLowerCase()=='Please Choose a Subscription'.toLowerCase()) {
          Future.delayed(
            Duration.zero,
                () {
              return Get.dialog(
                Align(
                  alignment: Alignment.center,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      height: Get.height * .25,
                      width: Get.height * .4,
                      decoration: BoxDecoration(
                        color: MyColors.lightCard(Get.context!),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 20.h),
                            Text(r.message.toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              style: MyColors.l111111_dtext(context!).regular18,),
                            SizedBox(height: 30.h),
                            CustomButtons.button(
                              height: Get.width>600?30.h:50.h,
                              text: MyStrings.subscriptionPlan.tr,
                              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                              fontSize: ResponsiveHelper.isTab(Get.context)?13.sp:18.sp,
                              onTap: () {
                                Get.back();
                                Get.back();
                                Get.toNamed(Routes.clientSubscriptionPlans);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false,
              );
            },
          );
        }else {
          Utils.showSnackBar(
              message: (r.message) ?? 'Job post creation failed',
              isTrue: false);
        }
      });
    }
  }

  void onUpdateJobClick() async {
     
       if (skillList.isEmpty) {
      Utils.showSnackBar(message: "Skills are required", isTrue: false);
    }
    // else if (tecSelectedDates.value.text.isEmpty) {
    //   Utils.showSnackBar(message: "Dates are required ", isTrue: false);
    // }
    else if (nationalityList.isEmpty) {
      Utils.showSnackBar(message: "Nationalities are required ", isTrue: false);
    } 
    // else if (experienceAmount.text.isEmpty) {
    //   Utils.showSnackBar(
    //       message: "Experience range is required ", isTrue: false);
    // } 
    else if (languageList.isEmpty) {
      Utils.showSnackBar(message: "Languages are required ", isTrue: false);
    }
    else if (selectedMonths.isEmpty) {
      Utils.showSnackBar(message: "Month are required ", isTrue: false);
    }
    // else if (ageAmount.text.isEmpty) {
    //   Utils.showSnackBar(message: "Age range is required ", isTrue: false);
    // }
     else if (tecPublishDate.value.text.isEmpty) {
      Utils.showSnackBar(message: "Publish date is required ", isTrue: false);
    } else if (tecEndDate.value.text.isEmpty) {
      Utils.showSnackBar(message: "End date is required ", isTrue: false);
    } 
    // else if (tecDescription.value.text.isEmpty) {
    //   Utils.showSnackBar(message: "Description is required ", isTrue: false);
    // } 
    else {
    CustomLoader.show(context!);
   isJobPostCreateButtonShown.value= false;
    // Capture other form data
    createJobPostRequestModel.value.clientId =
        appController.user.value.client?.id;
    createJobPostRequestModel.value.description = tecDescription.value.text;
    // createJobPostRequestModel.value.dates = requestDateList;
    createJobPostRequestModel.value.dates = prepareRequestDateList();
    createJobPostRequestModel.value.skills = skillList;
    createJobPostRequestModel.value.nationalities = nationalityList;
    createJobPostRequestModel.value.languages = languageList;
    createJobPostRequestModel.value.vacancy = int.parse(selectedVacancy.value);
    // make sure start date is not older than today
// Parse the date from the text field
    DateTime? parsedPublishedDate;
    try {
      parsedPublishedDate = DateTime.parse(tecPublishDate.value.text);
    } catch (e) {
      // If parsing fails, set it to today's date
      parsedPublishedDate = DateTime.now();
    }

// Get today's date without time for comparison
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

// Ensure the date is not older than today
    if (parsedPublishedDate.isBefore(normalizedToday)) {
      parsedPublishedDate = normalizedToday;
    }

// Assign the validated date to the model
    createJobPostRequestModel.value.publishedDate = parsedPublishedDate;
//doing for the end date so that the end date can't be  less tahn today
// Parse the date from the text field
    DateTime? parsedEndDate;
    try {
      parsedEndDate = DateTime.parse(tecEndDate.value.text);
    } catch (e) {
      // If parsing fails, set it to today's date
      parsedEndDate = DateTime.now();
    }

// Ensure the date is not older than today
    if (parsedEndDate.isBefore(normalizedToday)) {
      parsedEndDate = normalizedToday;
    }

// Assign the validated date to the model
    createJobPostRequestModel.value.endDate = parsedEndDate;

    // new text filed data instead of sliders
    // createJobPostRequestModel.value.minAge = ageAmount.text;
    // createJobPostRequestModel.value.maxAge = ageAmount.text;
    // createJobPostRequestModel.value.minRatePerHour =
    //   salaryAmount.text;
    // createJobPostRequestModel.value.maxRatePerHour =
    //    salaryAmount.text;
    // createJobPostRequestModel.value.minExperience =
    //     experienceAmount.text;
    // createJobPostRequestModel.value.maxExperience =
    //     experienceAmount.text;

        // new fields 
            createJobPostRequestModel.value.salary =
        salaryAmount.text;
    createJobPostRequestModel.value.experience =
        experienceAmount.text;
    createJobPostRequestModel.value.age =
        ageAmount.text;
            // if (salaryAmount.text.isEmpty) {
    //   Utils.showSnackBar(
    //       message: "Hourly Rate range is required", isTrue: false);
    // }
    //  else
   
    Either<CustomError, CommonResponseModel> response =
        await _apiHelper.editJobPost(
            createJobPostRequestModel: createJobPostRequestModel.value);
    Get.back();
    response.fold((l) {
      Logcat.msg(l.msg);
    }, (CommonResponseModel r) async {
      if ([200, 201].contains(r.statusCode) == true && r.status == "success") {
        // await Get.find<ClientHomePremiumController>().getMyJobPosts();
        // await Get.find<ClientHomePremiumController>().getJobPosts();
           isJobPostCreateButtonShown.value= false;
        Get.find<ClientPremiumRootController>().showExpandable.value = false;
        Get.back();
        // Reset the form model in case of success
        createJobPostRequestModel.value = CreateJobPostRequestModel();
        Utils.showSnackBar(
            message: (r.message) ?? "Job has been updated successfully",
            isTrue: true);
      } else {
        // Reset the form model in case of failure
        createJobPostRequestModel.value = CreateJobPostRequestModel();
        Utils.showSnackBar(
            message: (r.message) ?? 'Job post update failed', isTrue: false);
      }
           await Get.find<ClientHomePremiumController>().getMyJobPosts();
        await Get.find<ClientHomePremiumController>().getJobPosts();
    });

    Get.find<ClientHomePremiumController>().getMyJobPosts();
    Get.find<ClientHomePremiumController>().getJobPosts();
    }
  }

  void _loadUpdateData() {
    // revertToOriginalData();
    createJobPostRequestModel.value=CreateJobPostRequestModel();
    if (Get.arguments != null) {
      createJobPostRequestModel.value =
          Get.arguments; // Load passed arguments into the model
      type = "update"; // Set the operation type to update
      // Set individual form fields with the data from the model
      // Save a copy of the original data
      // originalCreateJobPostRequestModel.value = createJobPostRequestModel.value.copy();

      // tecExperience.value.text =
      //     "${createJobPostRequestModel.value.minExperience} - ${createJobPostRequestModel.value.maxExperience} years";

      // tecRatePerHour.value.text =
      //     "${createJobPostRequestModel.value.minRatePerHour} - ${createJobPostRequestModel.value.maxRatePerHour}";

      // tecAge.value.text =
      //     "${createJobPostRequestModel.value.minAge} - ${createJobPostRequestModel.value.maxAge} years";

      // selectedVacancy.value =
      //     (createJobPostRequestModel.value.vacancy ?? 2).toString();
      // new text filed data instead of sliders

      // ageAmount.text = (createJobPostRequestModel.value.age!.isEmpty || createJobPostRequestModel.value.age==null
      // )? "${createJobPostRequestModel.value.minAge??''}-${createJobPostRequestModel.value.maxAge??''}": "${createJobPostRequestModel.value.age}";

      // salaryAmount.text = (createJobPostRequestModel.value.salary!.isEmpty || createJobPostRequestModel.value.salary==null
      // )? "${createJobPostRequestModel.value.minRatePerHour??''}-${createJobPostRequestModel.value.maxRatePerHour??''}": "${createJobPostRequestModel.value.salary}";

      // experienceAmount.text =
      //     (createJobPostRequestModel.value.experience!.isEmpty || createJobPostRequestModel.value.experience==null
      // )? "${createJobPostRequestModel.value.minExperience??''}-${createJobPostRequestModel.value.maxExperience??''}": "${createJobPostRequestModel.value.experience}";
    ageAmount.text = (createJobPostRequestModel.value.age?.isEmpty ?? true)
    ? (createJobPostRequestModel.value.minAge == null && createJobPostRequestModel.value.maxAge == null
        ? "0"
        : "${createJobPostRequestModel.value.minAge ?? 0}-${createJobPostRequestModel.value.maxAge ?? 0}")
    : "${createJobPostRequestModel.value.age}";

salaryAmount.text = (createJobPostRequestModel.value.salary?.isEmpty ?? true)
    ? (createJobPostRequestModel.value.minRatePerHour == null && createJobPostRequestModel.value.maxRatePerHour == null
        ? "0"
        : "${createJobPostRequestModel.value.minRatePerHour ?? 0}-${createJobPostRequestModel.value.maxRatePerHour ?? 0}")
    : "${createJobPostRequestModel.value.salary}";

experienceAmount.text = (createJobPostRequestModel.value.experience?.isEmpty ?? true)
    ? (createJobPostRequestModel.value.minExperience == null && createJobPostRequestModel.value.maxExperience == null
        ? "0"
        : "${createJobPostRequestModel.value.minExperience ?? 0}-${createJobPostRequestModel.value.maxExperience ?? 0}")
    : "${createJobPostRequestModel.value.experience}";

      // Set dates for publish and end date
      // tecPublishDate.value.text =
      //     (createJobPostRequestModel.value.publishedDate ?? DateTime.now())
      //         .toIso8601String()
      //         .split('T')[0]; // Convert to YYYY-MM-DD format
      tecPublishDate.value.text =
          (createJobPostRequestModel.value.publishedDate != null &&
                  createJobPostRequestModel.value.publishedDate!
                      .isAfter(DateTime.now()))
              ? createJobPostRequestModel.value.publishedDate!
                  .toIso8601String()
                  .split('T')[0]
              : DateTime.now().toIso8601String().split('T')[0];

      // tecEndDate.value.text =
      //     (createJobPostRequestModel.value.endDate ?? DateTime.now())
      //         .toIso8601String()
      //         .split('T')[0];
      tecEndDate.value.text =
          (createJobPostRequestModel.value.endDate != null &&
                  createJobPostRequestModel.value.endDate!
                      .isAfter(DateTime.now()))
              ? createJobPostRequestModel.value.endDate!
                  .toIso8601String()
                  .split('T')[0]
              : DateTime.now().toIso8601String().split('T')[0];
      // Set skills, nationalities, and languages
      skillList.value = createJobPostRequestModel.value.skills ?? [];
      nationalityList.value =
          createJobPostRequestModel.value.nationalities ?? [];
      languageList.value = createJobPostRequestModel.value.languages ?? [];
      // Set the description field
      tecDescription.value.text = convertHtmlToPlainText(
          createJobPostRequestModel.value.description ?? "");
      // Handle the dates field properly
      if (createJobPostRequestModel.value.dates != null &&
          createJobPostRequestModel.value.dates!.isNotEmpty) {
        requestDateList.value =
            createJobPostRequestModel.value.dates!; // Load the list of dates

        // Set the selected dates text to show detailed info about the selected dates
        tecSelectedDates.value.text = requestDateList.map((dateModel) {
          DateTime? startDate = (dateModel.startDate is String
              ? DateTime.tryParse(dateModel.startDate!)
              : dateModel.startDate) as DateTime?;
          DateTime? endDate =
              (dateModel.endDate != null && dateModel.endDate is String
                  ? DateTime.tryParse(dateModel.endDate!)
                  : dateModel.endDate) as DateTime?;

          String formattedStartDate = startDate != null
              ? startDate.toIso8601String().split('T')[0]
              : 'N/A';
          String formattedEndDate =
              endDate != null ? endDate.toIso8601String().split('T')[0] : 'N/A';

          return "$formattedStartDate to $formattedEndDate";
        }).join(', ');
      } else {
        tecSelectedDates.value.text = 'No dates selected';
      }
      selectedMonths = convertRequestDateListToSelectedMonths(requestDateList);
         selectedVacancy.value = createJobPostRequestModel.value.vacancy.toString();

      // populating new 3 fields - salary, age, experience 
        //  ageAmount.text = createJobPostRequestModel.value.age ?? '';
        //  salaryAmount.text = createJobPostRequestModel.value.salary ?? '';
        //  experienceAmount.text = createJobPostRequestModel.value.experience ?? '';
      // **Populating the SliderController with initial values**
      // final sliderController = Get.find<SliderController>();

      // Add Age data to the SliderController
      // sliderController.addOrUpdateSliderData(
      //   'Age',
      //   createJobPostRequestModel.value.minAge?.toDouble() ?? 18.0,
      //   createJobPostRequestModel.value.maxAge?.toDouble() ?? 65.0,
      // );

      // // Add Experience data to the SliderController
      // sliderController.addOrUpdateSliderData(
      //   'Experience',
      //   createJobPostRequestModel.value.minExperience?.toDouble() ?? 0.0,
      //   createJobPostRequestModel.value.maxExperience?.toDouble() ?? 40.0,
      // );

      // Add Hourly Rate data to the SliderController
      // sliderController.addOrUpdateSliderData(
      //   'Hourly Rate',
      //   createJobPostRequestModel.value.minRatePerHour ?? "10.0",
      //   createJobPostRequestModel.value.maxRatePerHour ?? "100.0",
      // );
      log("loaded vacancy: ${createJobPostRequestModel.value.vacancy}");
    }
  }

  String convertHtmlToPlainText(String htmlString) {
    dom.Document document = parse(htmlString);
    String plainText = parse(document.body!.text).documentElement!.text;
    return plainText;
  }

  void onTapOutside(PointerDownEvent onTap) => Utils.unFocus();
}
