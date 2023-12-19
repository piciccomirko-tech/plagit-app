import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/nationality_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class CreateJobPostController extends GetxController {
  BuildContext? context;
  final AppController appController = Get.find<AppController>();
  final ApiHelper _apiHelper = Get.find();

  Rx<CreateJobPostRequestModel> createJobPostRequestModel = CreateJobPostRequestModel().obs;

  RxString selectedPosition = 'Manager'.obs;

  RxDouble minHourlyRate = 5.0.obs;
  RxDouble maxHourlyRate = 100.0.obs;
  Rx<TextEditingController> tecRatePerHour = TextEditingController().obs;

  RxList<String> skills = <String>[].obs;

  List<NationalityDetailsModel> nationalityList = <NationalityDetailsModel>[].obs;
  RxList<String> nationalities = <String>[].obs;

  RxList<String> languages = <String>[].obs;

  @override
  void onInit() {
    _getNationalityList();
    super.onInit();
  }

  void onPositionChange(String? position) {
    selectedPosition.value = position!;
  }

  void onHourlyRateSubmitClick() {
    tecRatePerHour.value.text =
        "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${minHourlyRate.value} - ${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${maxHourlyRate.value}";
    tecRatePerHour.refresh();
    Get.back();
  }

  void onSkillsChange(String? skill) {
    skills.add(skill ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(skills);
    skills.value = uniqueSet.toList();
    skills.refresh();
  }

  void onSkillClearClick({required int index}) {
    skills.removeAt(index);
    skills.refresh();
  }

  Future<void> _getNationalityList() async {
    Either<CustomError, NationalityModel> response = await _apiHelper.getNationalities();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (NationalityModel responseData) {
      if (responseData.status == "success") {
        nationalityList = responseData.nationalities ?? [];
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
    languages.add(language ?? "");
    LinkedHashSet<String> uniqueSet = LinkedHashSet<String>.from(languages);
    languages.value = uniqueSet.toList();
    languages.refresh();
  }

  void onLanguageClearClick({required int index}) {
    languages.removeAt(index);
    languages.refresh();
  }
}
