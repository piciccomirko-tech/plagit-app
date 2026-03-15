import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../../../common/app_info/app_info.dart';
import '../../../common/controller/app_controller.dart';
import '../../../common/local_storage/storage_helper.dart';
import '../../../common/utils/exports.dart';
import '../../../common/widgets/custom_dialog.dart';
import '../../../models/commons.dart';
import '../../../models/custom_error.dart';
import '../../../repository/api_helper.dart';
import '../../../routes/app_pages.dart';

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
      if (StorageHelper.hasToken) {
        _appController.setTokenFromLocal();
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (_) {
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> _getCommonData() async {
    try {
      final response = await _apiHelper.commons().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Commons API timed out'),
      );

      response.fold((CustomError customError) {
        _goToNextPage();
      }, (Commons commons) {
        _appController.setCommons(commons);

        final appVersion = commons.appVersion;
        if (appVersion == null || appVersion.isEmpty) {
          _goToNextPage();
          return;
        }

        final version = appVersion.first;

        if (version.serverMaintenance == true) {
          if (context != null) {
            CustomDialogue.information(
              context: context!,
              title: "Server Maintenance",
              description: version.serverMaintenanceMsg ?? "We will come back soon",
              buttonText: MyStrings.exit.tr,
              onTap: () {
                Utils.exitApp;
              },
            );
          } else {
            _goToNextPage();
          }
        } else if ((version.updateRequired ?? false) &&
            (version.appVersion != AppInfo.version)) {
          if (context != null) {
            CustomDialogue.information(
              context: context!,
              title: "${MyStrings.update.tr} ${MyStrings.available.tr}!",
              description:
                  "${MyStrings.newVersion.tr} (${version.appVersion}) ${MyStrings.updateApp.tr}",
              buttonText: MyStrings.update.tr,
              onTap: () {
                launchApp(
                    playStoreLink: version.playStoreLink ?? '',
                    appStoreLink: version.appStoreLink ?? '');
              },
            );
          } else {
            _goToNextPage();
          }
        } else {
          _goToNextPage();
        }
      });
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
