import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/translations/translations_service.dart';

import '../../../../common/utils/exports.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      value: StorageHelper.getLanguage,
      onChanged: (String? languageCode) {
        Get.updateLocale(Locale(languageCode!));
        StorageHelper.setLanguage = languageCode;
      },
      items: TranslationsService.locales.map((Locale locale) {
        return DropdownMenuItem<String>(
          value: locale.languageCode,
          child: Text(locale.languageCode),
        );
      }).toList(),
    );
  }
}
