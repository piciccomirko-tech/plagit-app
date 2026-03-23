import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/position_info_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/update_shortlist_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/widgets/client_short_listed_request_date_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/widgets/client_uniform_image_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/widgets/client_uniform_widget.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../common/shortlist_controller.dart';
import '../models/shortlisted_employees.dart';

class ClientShortlistedController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();

  final ShortlistController shortlistController = Get.find();

  RxString selectedOption = ''.obs;

  Rx<PositionInfoDetailsModel> positionInfo = PositionInfoDetailsModel().obs;
  RxBool uniformImageDataLoaded = false.obs;

  UpdateShortListRequestModel? updateShortListRequestModel;

  String? employeePositionId;
 @override
  void onInit() {
    super.onInit(); 

  shortlistController.selectedForHire.refresh();
  // shortlistController.isDateRangeSetForSelectedUser();
  // shortlistController.fetchShortListEmployees();
      log(" hired emp at clinet: ${shortlistController.selectedForHire.toJson()}");
        log(" hired emp total client : ${shortlistController.totalShortlisted.value}");
  }
//   @override 
//   void onClose() { 
//     super.onClose();
// shortlistController.selectedForHire.close();
//   }
  void onSelectClick(ShortList shortList) {
    shortlistController.onSelectClick(shortList);
    // shortlistController.selectedForHire.refresh();
  }

  Future<void> onBookAllClick() async {
    shortlistController.selectedForHire.refresh();
    if (shortlistController.shortList.isEmpty) {
      log("shortlistController.shortList: ${shortlistController.shortList}");
      CustomDialogue.information(
        context: context!,
        title: "Empty Shortlist",
        description: "Please add employee to shortlist then continue",
      );
    } else if (shortlistController.isDateRangeSetForSelectedUser()) {
          // shortlistController.selectedForHire.refresh();
      Get.toNamed(Routes.clientTermsConditionForHire);
    } else {

      CustomDialogue.information(
        context: context!,
        title: MyStrings.invalidInput.tr, 
        description: MyStrings.selectDateTimeRangeToHire.tr,
      );
    }
  }

  void onDaysSelectedClick({required List<RequestDateModel> requestDateList, required String shortListId}) {
    if (requestDateList.isEmpty) {
      Utils.showSnackBar(
          message: MyStrings.youHaventSelectedDates.tr, isTrue: false);
    } else {
      Get.dialog(Dialog(
        backgroundColor: MyColors.lightCard(Get.context!),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.0.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: ClientShortListedRequestDateWidget(requestDateList: requestDateList, shortListId: shortListId),
      ));
    }
  }

  void onUniformClick(
      {required String shortListId, required List<RequestDateModel> requestDateList, required String positionId}) {
    updateShortListRequestModel =
        UpdateShortListRequestModel(shortListId: shortListId, requestDateList: requestDateList, uniformMandatory: null);
    employeePositionId = positionId;
    Get.dialog(Dialog(
      backgroundColor: MyColors.lightCard(Get.context!),
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: ClientUniformWidget(),
    ));
  }

  void onDateRemoveClick(
      {required int index, required String shortListId, required List<RequestDateModel> requestDateList}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: "${MyStrings.confirm.tr}?",
      msg: "${MyStrings.sureWantTo.tr} ${MyStrings.remove.tr} ${MyStrings.thisRange.tr}?",
      confirmButtonText: MyStrings.remove.tr,
      onConfirm: () async {
        Get.back();
        requestDateList.removeAt(index);
        UpdateShortListRequestModel updateShortListRequestModel = UpdateShortListRequestModel(
            shortListId: shortListId, requestDateList: requestDateList, uniformMandatory: null);
        await updateShortListDateOrTime(updateShortListRequestModel: updateShortListRequestModel);
      },
    );
  }

  Future<void> updateShortListDateOrTime({required UpdateShortListRequestModel updateShortListRequestModel}) async {
    CustomLoader.show(context!);
    Either<CustomError, Response> response =
        await _apiHelper.updateShortlistItem(updateShortListRequestModel: updateShortListRequestModel);
    CustomLoader.hide(context!);
    Get.back();
    response.fold((l) {
      Logcat.msg(l.msg);
    }, (r) async {
      if ([200, 201].contains(r.statusCode)) {
        await shortlistController.fetchShortListEmployees();
      } else {
        CustomDialogue.information(
          context: Get.context!,
          title: MyStrings.error.tr,
          description: MyStrings.somethingWentWrong.tr,
        );
      }
    });
  }

  void onUniformChange(String? value) {
    selectedOption.value = value ?? '';
    if (selectedOption.value == 'Yes') {
      updateShortListRequestModel?.uniformMandatory = true;
    } else {
      updateShortListRequestModel?.uniformMandatory = false;
    }
    updateShortListDateOrTime(updateShortListRequestModel: updateShortListRequestModel!);
  }

  void onViewUniformClick() async {
    Either<CustomError, PositionInfoModel> responseData =
        await _apiHelper.getPositionInfo(positionId: employeePositionId ?? '');
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
