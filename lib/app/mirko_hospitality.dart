import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import 'common/app_info/app_info.dart';
import 'common/controller/app_controller.dart';
import 'common/local_storage/storage_helper.dart';
import 'common/style/theme.dart';
import 'common/utils/initializer.dart';
import 'routes/app_pages.dart';

class MirkoHospitality extends StatelessWidget {
  const MirkoHospitality({super.key});

  @override
  Widget build(BuildContext context) {
    // i dont know why MediaQuery.of(context).viewInsets.bottom not work in bottom sheet on this project
    // that's why store MediaQuery.of(context).viewInsets.bottom (basically keyboard height) in a observable variable

    Get.find<AppController>().bottomPadding.value = MediaQuery.of(context).viewInsets.bottom;
    final Locale locale = _loadLocale();
    print('MirkoHospitality.build: ${locale}');

    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return GetMaterialApp(
          title: AppInfo.appName,
          initialRoute: Routes.splash,
          getPages: AppPages.routes,
          initialBinding: InitialBindings(),
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.rightToLeft,
          translations: TranslationsService(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: locale,
          fallbackLocale: locale,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'AE'),
            Locale('it', 'IT'), // Bangla
            // Add more supported locales
          ],
        );
      },
    );
  }

  Locale _loadLocale() {
    Locale locale = const Locale("en", "US");
    print('MirkoHospitality._loadLocale: ${StorageHelper.getLanguage}');
    if (StorageHelper.getLanguage == "en") {
      print('MirkoHospitality._loadLocale 1');
      locale = const Locale("en", "US");
    } else if (StorageHelper.getLanguage == "ar") {
      print('MirkoHospitality._loadLocale 2');
      locale = const Locale("ar", "AE");
    } else {
      print('MirkoHospitality._loadLocale 3');
      locale = const Locale("it", "IT");
    }
    print('Local: $locale');
    return locale;
  }
}
