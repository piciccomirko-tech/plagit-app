import 'package:mh/app/common/translations/language_model.dart';
import 'package:mh/app/common/translations/translations_service.dart';

import '../../../../../common/local_storage/storage_helper.dart';
import '../../../../../common/utils/exports.dart';
import '../../../../../helpers/responsive_helper.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      initialValue: Get.locale?.languageCode??"",
      color: MyColors.lightCard(context),
      itemBuilder: (BuildContext context) {
        return TranslationsService.languageList.map((LanguageModel language) {
          return PopupMenuItem<String>(
            
            value: language.languageCode,
            child: Row(
              children: [
                Text(language.imageUrl, style:  TextStyle(fontSize: ResponsiveHelper.isTab(Get.context)? 16.sp:20.sp)), // Assuming imageUrl is a URL
                const SizedBox(width: 5),
                Text(language.languageCode, style: ResponsiveHelper.isTab(Get.context)? MyColors.l5C5C5C_dwhite(context).medium13: MyColors.l5C5C5C_dwhite(context).medium17),
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(TranslationsService.languageList.singleWhere((element) => element.languageCode == Get.locale?.languageCode).imageUrl, style:  TextStyle(fontSize: Get.width>600?30:20)),
          const SizedBox(width: 5),
          Text(
              Get.locale?.languageCode??"en", style: Get.width>600? MyColors.l5C5C5C_dwhite(context).medium13:MyColors.l5C5C5C_dwhite(context).medium17),
           Icon(Icons.arrow_drop_down, size:20.sp,color: MyColors.c_C6A34F),
        ],
      ),
      onSelected: (String languageCode){
        Get.updateLocale(Locale(languageCode));
        StorageHelper.setLanguage = languageCode;
      },
    );
  }
}
