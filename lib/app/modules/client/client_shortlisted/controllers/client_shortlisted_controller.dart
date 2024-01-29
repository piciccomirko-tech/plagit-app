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

  void onSelectClick(ShortList shortList) {
    shortlistController.onSelectClick(shortList);
  }

  void onBookAllClick() {
    if (shortlistController.shortList.isEmpty) {
      CustomDialogue.information(
        context: context!,
        title: "Empty Shortlist",
        description: "Please add employee to shortlist then continue",
      );
    } else if (shortlistController.isDateRangeSetForSelectedUser()) {
      Get.toNamed(Routes.clientTermsConditionForHire);
    } else {
      CustomDialogue.information(
        context: context!,
        title: "Invalid Input",
        description: "Please select the date and time range for when you want to hire an employee",
      );
    }
  }

  void onDaysSelectedClick({required List<RequestDateModel> requestDateList, required String shortListId}) {
    if (requestDateList.isEmpty) {
      Utils.showSnackBar(
          message: 'You have not any selected dates currently.\nPlease select the dates first', isTrue: false);
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
      title: MyStrings.confirm.tr,
      msg: "Are you sure you want to remove this range?",
      confirmButtonText: "Remove",
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
          title: "Error",
          description: "Something went wrong",
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
