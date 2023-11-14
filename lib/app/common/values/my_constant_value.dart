import 'package:get/get.dart';

import '../../enums/app_languages.dart';

class MyConstantValue {
  MyConstantValue._();

  static String get defaultAppLanguage => AppLanguages.english.name;
  static String get defaultAppTheme => AppLanguages.english.name;

  static ResponsiveScreenSettings responsiveScreenSettings = const ResponsiveScreenSettings(
    desktopChangePoint: 600,
    tabletChangePoint: 480,
    watchChangePoint: 300,
  );
}
