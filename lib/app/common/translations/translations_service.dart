import 'package:get/get.dart';
import 'package:mh/app/common/translations/ar_AE.dart';
import 'package:mh/app/common/translations/en_US.dart';
import 'package:mh/app/common/translations/it_IT.dart';
import 'package:mh/app/common/translations/language_model.dart';

class TranslationsService extends Translations {
  static List<LanguageModel> languageList = <LanguageModel>[
    LanguageModel(
      imageUrl: "🇬🇧",
      countryName: 'United Kingdom',
      languageCode: 'en',
    ),
    LanguageModel(
      imageUrl: "🇦🇪",
      countryName: 'Dubai',
      languageCode: 'ar',
    ),
    LanguageModel(
      imageUrl: "🇮🇹",
      countryName: 'Italy',
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
