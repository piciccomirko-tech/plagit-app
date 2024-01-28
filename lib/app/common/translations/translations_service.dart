import 'package:get/get.dart';
import 'package:mh/app/common/translations/ar_AE.dart';
import 'package:mh/app/common/translations/en_US.dart';
import 'package:mh/app/common/translations/it_IT.dart';
import 'package:mh/app/common/translations/language_model.dart';

class TranslationsService extends Translations {
  static List<LanguageModel> languageList = <LanguageModel>[
    LanguageModel(
      imageUrl: "🇺🇸",
      languageName: 'en',
      countryCode: 'US',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: "🇦🇪",
      languageName: 'ar', // Arabic
      countryCode: 'AE',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: "🇮🇹",
      languageName: 'it', // Italian
      countryCode: 'IT',
      languageCode: 'it',
    ),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': english,
        'ar': arabic,
        'it': italian,
      };
}
