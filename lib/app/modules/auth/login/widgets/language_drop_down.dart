import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/app/common/translations/language_model.dart';
import 'package:mh/app/common/translations/translations_service.dart';
import '../../../../common/utils/exports.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      initialValue: StorageHelper.getLanguage,
      color: MyColors.lightCard(context),
      itemBuilder: (BuildContext context) {
        return TranslationsService.languageList.map((LanguageModel language) {
          return PopupMenuItem<String>(
            value: language.languageCode,
            child: Row(
              children: [
                Text(language.imageUrl, style: const TextStyle(fontSize: 20)), // Assuming imageUrl is a URL
                const SizedBox(width: 5),
                Text(language.languageCode, style: MyColors.l5C5C5C_dwhite(context).medium16),
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(TranslationsService.languageList.singleWhere((element) => element.languageCode == StorageHelper.getLanguage).imageUrl, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 5),
          Text(
              StorageHelper.getLanguage, style: MyColors.l5C5C5C_dwhite(context).medium16),
          const Icon(Icons.arrow_drop_down, color: MyColors.c_C6A34F),
        ],
      ),
      onSelected: (String languageCode) {
        Get.updateLocale(Locale(languageCode));
        StorageHelper.setLanguage = languageCode;
      },
    );
  }
}
