import 'package:get/get.dart';

import '../../enums/app_languages.dart';
import 'en_us.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        AppLanguages.english.name: en,
      };
}
