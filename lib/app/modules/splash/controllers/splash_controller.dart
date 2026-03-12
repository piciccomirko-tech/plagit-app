import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../../common/app_info/app_info.dart';
import '../../../common/controller/app_controller.dart';
import '../../../common/utils/exports.dart';
import '../../../routes/app_pages.dart';
import '../../../common/local_storage/storage_helper.dart';
import '../../../common/widgets/custom_dialog.dart';
import '../../../models/commons.dart';
import '../../../models/custom_error.dart';
import '../../../repository/api_helper.dart';

class SplashController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final AppController _appController = Get.find();

  @override
  void onReady() {
    _initialize();
    super.onReady();
  }

  void _initialize() {
    Future.delayed(const Duration(seconds: 1), _getCommonData);
  }

  void _goToNextPage() {
    try {
      if (!StorageHelper.getOnboardingSeen) {
        Get.offAllNamed(Routes.onboarding);
      } else {
        _appController.setTokenFromLocal();
      }
    } catch (_) {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  Future<void> _getCommonData() async {
    try {
      final response = await _apiHelper
          .commons()
          .timeout(const Duration(seconds: 10));

      final isError = response.isLeft();

      if (isError) {
        _goToNextPage();
        return;
      }

      final commons = response.getOrElse(() => throw Exception());
      _appController.setCommons(commons);

      final appVersion = commons.appVersion?.first;

      if (appVersion != null && (appVersion.serverMaintenance ?? false)) {
        CustomDialogue.information(
          context: context!,
          title: "Server Maintenance",
          description: appVersion.serverMaintenanceMsg ?? "We will come back soon",
          buttonText: MyStrings.exit.tr,
          onTap: () {
            Utils.exitApp;
          },
        );
      } else if (appVersion != null &&
          (appVersion.updateRequired ?? false) &&
          (appVersion.appVersion != AppInfo.version)) {
        CustomDialogue.information(
          context: context!,
          title: "${MyStrings.update.tr} ${MyStrings.available.tr}!",
          description:
              "${MyStrings.newVersion.tr} (${appVersion.appVersion}) ${MyStrings.updateApp.tr}",
          buttonText: MyStrings.update.tr,
          onTap: () {
            launchApp(
                playStoreLink: appVersion.playStoreLink ?? '',
                appStoreLink: appVersion.appStoreLink ?? '');
          },
        );
      } else {
        _goToNextPage();
      }
    } catch (_) {
      _goToNextPage();
    }
  }

  void launchApp({required String playStoreLink, required String appStoreLink}) async {
    try {
      Uri url = Uri.parse(Platform.isAndroid ? playStoreLink : appStoreLink);
      if (await canLaunchUrl(url)) {
        Platform.isAndroid
            ? await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication)
            : await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (_) {}
  }
}

