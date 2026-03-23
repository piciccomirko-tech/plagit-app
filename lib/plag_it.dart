import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import 'app/common/app_info/app_info.dart';
import 'app/common/controller/app_controller.dart';
import 'app/common/local_storage/storage_helper.dart';
import 'app/common/style/theme_controller.dart';
import 'app/common/utils/initializer.dart';
import 'app/routes/app_pages.dart';

class PlagIt extends StatelessWidget {
  PlagIt({super.key});
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // i don't know why MediaQuery.of(context).viewInsets.bottom not work in bottom sheet on this project
    // that's why store MediaQuery.of(context).viewInsets.bottom (basically keyboard height) in a observable variable

    Get.find<AppController>().bottomPadding.value =
        MediaQuery.of(context).viewInsets.bottom;
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return Obx(
          () => GetMaterialApp(
            title: AppInfo.appName,
            initialRoute: Routes.loginRegisterHints,
            getPages: AppPages.routes,
            initialBinding: InitialBindings(),
            debugShowCheckedModeBanner: false,
            //defaultTransition: Transition.rightToLeft,
            translations: TranslationsService(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale(StorageHelper.getLanguage),
            fallbackLocale: Locale(StorageHelper.getLanguage),
            // theme: AppTheme.light,
            // darkTheme: AppTheme.dark,
            // themeMode: ThemeMode.system,

            themeMode: themeController.themeMode.value,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'AE'),
              Locale('it', 'IT'), // Bangla
              // Add more supported locales
            ],
          ),
        );
      },
    );
  }
}
