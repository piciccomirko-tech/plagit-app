import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mh/app/common/translations/language_model.dart';
import 'package:mh/app/common/translations/translations_service.dart';

import '../../../../common/utils/exports.dart';

class LanguageDropdown extends StatelessWidget {
  final String tag;
  const LanguageDropdown({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: DropdownButtonFormField2(
                decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                  border: InputBorder.none,
                ),
                isExpanded: true,
                value: "en", //StorageHelper.getLanguage,
                onChanged: (String? languageCode) {
                  Get.updateLocale(Locale(languageCode ?? "en"));
                  //StorageHelper.setLanguage = languageCode ?? "en";
                },
                items: TranslationsService.languageList.map((LanguageModel language) {
                  return DropdownMenuItem<String>(
                      value: language.languageCode,
                      child: Text("${language.imageUrl}${language.languageName}"));
                }).toList(),
              ),
            ),
          );
  }
}
