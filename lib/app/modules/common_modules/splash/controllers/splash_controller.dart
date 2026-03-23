import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/models/commons.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/deep_link_service/deep_link_service.dart';
import '../../../../common/local_storage/storage.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../common/utils/exports.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../models/dropdown_item.dart';
import '../../../../models/saved_post_model.dart';

var savedPostList = <SavedPostModel>[].obs;

class SplashController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController _appController = Get.find();

  // final RxList<SavedPostModel> skillList = <SavedPostModel>[].obs;

  @override
  void onReady() {
    _initialize();
    if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
      fetchSavedPost();
    }
    super.onReady();
  }

  void _initialize() {
    Future.delayed(const Duration(seconds: 1), _getPositions);
    Future.delayed(const Duration(seconds: 1), _getCommonData);
  }

  Future<void> _goToNextPage() async {
    _appController.setTokenFromLocal();
    // Mark deep link service as initialized after app is ready
    Get.find<DeepLinkService>().markInitialized();
  }

  Future<void> _getCommonData() async {
    await _apiHelper.commons().then((response) {
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getCommonData);
      }, (Commons commons) {
        _appController.setCommons(commons);
        _appController.currentUserEmail(Storage.getValue<String>('currentEmail') ?? '');

        if (commons.appVersion!.first.serverMaintenance!) {
          Future.delayed(
            Duration.zero,
                () {
              return Get.dialog(
                WillPopScope(
                  onWillPop: () async {
                    exit(0);
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        height: Get.height * .65,
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
                              SizedBox(height: 30.h),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: HtmlWidget(buildAsync: false,commons.appVersion!.first.serverMaintenanceMsg ??
                                      MyStrings.weWillComeBackSoon.tr),),
                              ),
                              SizedBox(height: 15.h),
                              CustomButtons.button(
                                height: Get.width>600?30.h:50.h,
                                text: MyStrings.exit.tr,
                                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                fontSize: ResponsiveHelper.isTab(Get.context)?13.sp:18.sp,
                                onTap: () {
                                  exit(0);
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
        } else if ((commons.appVersion!.first.updateRequired ?? false) &&
            (commons.appVersion!.first.appVersion != AppInfo.version)) {
          if (kDebugMode) {
            print('SplashController._getCommonData:${commons.appVersion!.first.appVersion}   ${AppInfo.version}');
          }
          CustomDialogue.information(
            context: context!,
            title: "${MyStrings.update.tr} ${MyStrings.available.tr}!",
            description:
                "${MyStrings.newVersion.tr} (${commons.appVersion!.first.appVersion}) ${MyStrings.updateApp.tr}",
            buttonText: MyStrings.update.tr,
            onTap: () {
              launchApp(
                  playStoreLink: commons.appVersion?.first.playStoreLink ?? '',
                  appStoreLink: commons.appVersion?.first.appStoreLink ?? '');
              /*if ((commons.appVersion!.first.updateRequired ?? false)) {
                Utils.exitApp;
              } else {
                _goToNextPage();
              }*/
            },
          );
        } else {
          _goToNextPage();
        }
      });
    });
  }

  Future<void> _getPositions() async{
    await _apiHelper.positions().then((response) {
      response.fold((CustomError customError) {
      }, (List<DropdownItem> positions) {
        _appController.setPositions(positions);
      });
    });
  }

  void launchApp(
      {required String playStoreLink, required String appStoreLink}) async {
    try {
      Uri url = Uri.parse(Platform.isAndroid ? playStoreLink : appStoreLink);
      if (await canLaunchUrl(url)) {
        Platform.isAndroid
            ? await launchUrl(url,
                mode: LaunchMode.externalNonBrowserApplication)
            : await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (_) {}
  }

  void fetchSavedPost() async {
    var result = await _apiHelper.getSavedPost();
    result.fold(
      (failure) {
        if (kDebugMode) {
          print("Failed to fetch skills: $failure");
        }
      },
      (skills) {
        savedPostList.clear();
        savedPostList.addAll(skills);
        if (kDebugMode) {
          print('SplashController.fetchSavedPost: ${savedPostList.length}');
        }
      },
    );
  }
}
