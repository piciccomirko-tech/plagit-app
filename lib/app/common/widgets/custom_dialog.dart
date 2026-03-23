import 'package:lottie/lottie.dart';
import 'package:mh/app/helpers/responsive_helper.dart';

import '../utils/exports.dart';
import 'custom_loader.dart';

class CustomDialogue {
  static Future noInternetError({
    required BuildContext context,
    Function()? onRetry,
  }) =>
      _errorDialog(
        context: context,
        onRetry: onRetry,
        logo: MyAssets.lottie.noWifi,
        title: MyStrings.noInternetConnection.tr,
        details: MyStrings.connectionError.tr,
      );

  static Future apiError({
    required BuildContext context,
    Function()? onRetry,
    required int errorCode,
    String? msg,
  }) =>
      _errorDialog(
        context: context,
        onRetry: onRetry,
        logo: MyAssets.lottie.warning,
        title: "${MyStrings.error.tr} $errorCode", 
        details: msg ?? MyStrings.serverIssue.tr,
      );

  static Future typeConversionError({
    required BuildContext context,
    Function()? onRetry,
  }) =>
      _errorDialog(
        context: context,
        onRetry: onRetry,
        logo: MyAssets.lottie.error,
        title: MyStrings.oops.tr,
        details: MyStrings.somethingMismatch.tr,
      );

  static Future serverError({
    required BuildContext context,
    Function()? onRetry,
    String msg = MyStrings.somethingWentWrong,
  }) =>
      _errorDialog(
        context: context,
        onRetry: onRetry,
        logo: MyAssets.lottie.error,
        title: MyStrings.serverError.tr,
        details: msg.tr,
      );

  static Future _errorDialog({
    required BuildContext context,
    Function()? onRetry,
    required String logo,
    required String title,
    required String details,
  }) =>
      Future.delayed(
        Duration.zero,
        () {
          return Get.dialog(
            WillPopScope(
              onWillPop: () async => true,
              child: Align(
                alignment: Alignment.center,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    height: 350.h,
                    width: 340.w,
                    decoration: BoxDecoration(
                      color: MyColors.lightCard(context),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Lottie.asset(logo, height: Get.width>600? 180.h: 120.h, width: Get.width>600? 180.h: 120.w),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if(onRetry != null)
                                  Text(
                                    title,
                                    style: (MyColors.l111111_dtext(context).semiBold22).copyWith(fontSize: Get.width>600? 14.sp:10.sp),
                                  ),
                                   SizedBox(height: 30.h),
                                  Text(
                                    details,
                                    textAlign: TextAlign.center,
                                    style: MyColors.l50555C_dtext(context).medium15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: CustomButtons.button(
                                height: Get.width>600?35.h:50.h,
                                text: onRetry == null ?  MyStrings.close.tr: MyStrings.retry.tr,
                                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                onTap: () {
                                  CustomLoader.hide(context);

                                  if (onRetry == null) {
                                    CustomLoader.hide(context);
                                  } else {
                                    onRetry();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );
        },
      );

  static Future information({
    required BuildContext context,
    required String title,
    required String description,
    Function()? onTap,
    String buttonText = "I Understand",
    // MyStrings.iUnderstand.tr
  }) =>
      Future.delayed(
        Duration.zero,
        () {
          return Get.dialog(
            WillPopScope(
              onWillPop: () async => true,
              child: Align(
                alignment: Alignment.center,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                   height: Get.height * .45,
                    width: Get.height * .4,
                    decoration: BoxDecoration(
                      color: MyColors.lightCard(context),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 25.h),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: ResponsiveHelper.isTab(Get.context)?MyColors.l111111_dtext(context).semiBold14:MyColors.l111111_dtext(context).semiBold22,
                          ),
                          SizedBox(height: 30.h),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                description,
                                textAlign: TextAlign.center,
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                                style: ResponsiveHelper.isTab(Get.context)?MyColors.l50555C_dtext(context).regular10:MyColors.l50555C_dtext(context).regular15,
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          CustomButtons.button(
                            height: Get.width>600?30.h:50.h,
                            text: buttonText,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                            fontSize: ResponsiveHelper.isTab(Get.context)?13.sp:18.sp,
                            onTap: () {
                              CustomLoader.hide(context);
                              if (onTap != null) {
                                onTap();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          );
        },
      );

  static dynamic appExit(BuildContext context) {
    confirmation(
      context: context,
      title: MyStrings.exitApp.tr,
      msg: MyStrings.areYouSureExit.tr,
      confirmButtonText: "Exit", 
      // MyStrings.exit.tr
      onConfirm: Utils.exitApp,
    );
  }

  static dynamic confirmation({
    required BuildContext context,
    required String title,
    required String msg,
    required String confirmButtonText,
    required Function() onConfirm,
  }) {
    Future.delayed(
      Duration.zero,
      () {
        return Get.dialog(
          WillPopScope(
            onWillPop: () async => true,
            child: Align(
              alignment: Alignment.center,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  height: Get.height * .3,
                  width: Get.height * .4,
                  decoration: BoxDecoration(
                    color: MyColors.lightCard(context),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 25.h),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Get.width>600?MyColors.l111111_dtext(context).semiBold15:MyColors.l111111_dtext(context).semiBold22,
                        ),
                        SizedBox(height: 30.h),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              msg,
                              textAlign: TextAlign.center,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: Get.width>600?MyColors.l50555C_dtext(context).regular12:MyColors.l50555C_dtext(context).regular15,
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Padding(
                          padding:   EdgeInsets.symmetric(horizontal: 20.sp),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  CustomLoader.hide(context);
                                },
                                child: Text(
                                  MyStrings.close.tr,
                                  style: Get.width>600?MyColors.text.semiBold12:MyColors.text.semiBold16,
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: CustomButtons.button(
                                  height: Get.width>600? 30.h: 50.h,
                                  text: confirmButtonText,
                                  margin: EdgeInsets.zero,
                                  fontSize: Get.width>600?10.sp:16.sp,
                                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                  onTap: onConfirm,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      },
    );
  }
}
