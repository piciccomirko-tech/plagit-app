import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/translations/language_model.dart';
import 'package:mh/app/common/translations/translations_service.dart';

import '../../../../common/utils/exports.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: DropdownButtonFormField2(
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: MyColors.c_C6A34F.withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
            border: InputBorder.none,
          ),
          isExpanded: true,
          value: "en",//StorageHelper.getLanguage,
          onChanged: (String? languageCode) {
            Get.updateLocale(Locale(languageCode ?? "en"));
            //StorageHelper.setLanguage = languageCode ?? "en";
          },
          items: TranslationsService.languageList.map((LanguageModel language) {
            return DropdownMenuItem<String>(
                value: language.languageCode,
                child: Text("${language.imageUrl} ${language.languageName}", style: MyColors.black.medium16));
          }).toList(),
        ),
      ),
    );
  }
}
