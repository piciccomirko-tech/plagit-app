import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../models/client_subscription_plan_details.dart';
import '../models/client_subscription_plan_model.dart';
import '../models/upgrade_plan_response_model.dart';

class ClientSubscriptionPlanController extends GetxController {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();
  final isLoading=false.obs;
  final isUpgradingPlan=false.obs;
  final currentSubscriptionPlanId=''.obs;
  final tokenId=''.obs;
  final selectedPlanIndex=0.obs;
  final activeSubscriptionPlanIndex=0.obs;
  // final _clientSubscriptionModel = ClientSubscriptionPlanModel().obs;
  // ClientSubscriptionPlanModel get clientSubscriptionModelResponse => _clientSubscriptionModel.value;
  final packageList=<Result>[].obs;

  @override
  void onInit() {
    super.onInit();
    getClientSubscriptionDetails();
  }

  Future<void> getClientSubscriptionPlanList() async {
    isLoading(true);
    _apiHelper.getClientSubscriptionPlanList().then(
            (Either<CustomError, ClientSubscriptionPlanModel> responseData) {
              isLoading(false);
          responseData.fold((CustomError customError) {
            // Utils.errorDialog(context!, customError..onRetry = checkSubscription);
          }, (ClientSubscriptionPlanModel response) async {
            if (response.status == "success") {
              packageList.value = (response.result ?? [])
                ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
              activeSubscriptionPlanIndex.value = packageList.indexWhere((package) => package.id == currentSubscriptionPlanId.value);
            } else {
              Utils.showSnackBar(message: response.message ?? "", isTrue: false);
            }
          });
        });
  }

  Future<void> getClientSubscriptionDetails() async {
    isLoading(true);
    _apiHelper.getClientSubscriptionDetails(userId: appController.user.value.userId).then(
            (Either<CustomError, ClientSubscriptionPlanDetails> responseData) {
              getClientSubscriptionPlanList();
          responseData.fold((CustomError customError) {
            // Utils.errorDialog(context!, customError..onRetry = checkSubscription);
          }, (ClientSubscriptionPlanDetails response) async {
            if (response.status == "success") {
              currentSubscriptionPlanId.value=response.details!.subscription!=null && response.details!.subscription!.plan!=null?response.details!.subscription!.plan!.id!:'';
              tokenId.value=response.details!.tokenId??'';
            } else {
            }
          });
        });
  }

  Future<void> upgradePlan() async {
    if(isUpgradingPlan.value==true){
      return;
    }
    if(tokenId.value==""){
      Get.toNamed(Routes.cardAdd, arguments: [
        Get.find<AppController>().user.value.client?.email,
        'clientSubscriptionPlans'
      ]);
      return;
    }
    isUpgradingPlan(true);
    double finalPrice = packageList[selectedPlanIndex.value].monthlyCharge??0.0;

    if (packageList[selectedPlanIndex.value].hasDiscount == true) {
      if (packageList[selectedPlanIndex.value].discountType == "percent") {
        finalPrice = finalPrice - (finalPrice * (packageList[selectedPlanIndex.value].discount??0.0) / 100);
      } else if (packageList[selectedPlanIndex.value].discountType == "fixed") {
        finalPrice = finalPrice - (packageList[selectedPlanIndex.value].discount??0);
      }
    }
    var extendedMonth=packageList[selectedPlanIndex.value].planDuration??0;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String endDate = DateFormat('yyyy-MM-dd').format(DateTime.now().copyWith(month: DateTime.now().month + extendedMonth,));
    Map<String, dynamic> payLoad = {
    'plan': packageList[selectedPlanIndex.value].id,
    'currency': 'USD',
    'monthlyCharge': finalPrice,
    'startDate': today,
    'endDate': endDate,
    'paymentDate': today,
    };
    if (extendedMonth>=1200) {
      payLoad.remove('endDate');
    }
    await _apiHelper.upgradePlan(payLoad: jsonEncode(payLoad)).then(
            (Either<CustomError, UpgradePlanResponseModel> responseData) {
              isUpgradingPlan(false);
          responseData.fold((CustomError customError) {
            if (kDebugMode) {
              print(customError.msg);
              print(customError.errorCode.toString());
            }
            if (customError.errorCode == 500) {
              Get.toNamed(Routes.cardAdd, arguments: [
                Get.find<AppController>().user.value.client?.email,
                'clientSubscriptionPlans'
              ]);}
          }, (UpgradePlanResponseModel response) async {
            if (kDebugMode) {
              print(response.status);
              print(response.message);
              print(response.statusCode.toString());
              print(response.details.toString());
            }
            if (response.status == "success") {
              Utils.showSnackBar(message: 'Payment successful! Your plan is now active', isTrue: true);
              Get.offAndToNamed(Routes.clientPremiumRoot);
            } else if (response.status == "error" && (response.statusCode == 400 || response.statusCode == 500)) {
              Utils.showSnackBar(message:response.message??'Please try again', isTrue: false);
            } else {
              Utils.showSnackBar(message:response.message??'Please try again', isTrue: false);
            }
          });
        });
  }

  Future<void> onRefresh() async {
    await getClientSubscriptionPlanList();
  }
}
