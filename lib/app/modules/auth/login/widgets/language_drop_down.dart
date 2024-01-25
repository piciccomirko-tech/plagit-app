import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/translations/language_model.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import 'package:mh/app/modules/auth/login/controllers/login_controller.dart';

import '../../../../common/utils/exports.dart';

class LanguageDropdown extends GetWidget<LoginController> {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: MyColors.c_C6A34F),
      ),
      child: DropdownButton2<String>(
        underline: const Wrap(),
        value: StorageHelper.getLanguage,
        onChanged: controller.onLanguageChanged,
        items: TranslationsService.languageList.map((LanguageModel language) {
          return DropdownMenuItem<String>(
            value: language.languageCode,
            child: Text("${language.imageUrl} ${language.languageName}")

          );
        }).toList(),
      ),
    );
  }
}
