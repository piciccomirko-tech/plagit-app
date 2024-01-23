import 'dart:ui';

import 'package:get/get.dart';
import 'package:mh/app/common/translations/ar_AE.dart';
import 'package:mh/app/common/translations/en_US.dart';
import 'package:mh/app/common/translations/it_IT.dart';

class TranslationsService extends Translations {
  static const fallbackLocale = Locale('en', 'US');
  static final List<Locale> locales = [
    const Locale('en', 'US'),
    const Locale('ar', 'AE'),
    const Locale('it', 'IT'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': english,
        'ar_AE': arabic,
        'it_IT': italiano,
      };
}
