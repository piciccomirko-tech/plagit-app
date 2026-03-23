import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';

import '../../../../common/local_storage/storage_helper.dart';
import '../../../../common/translations/translations_service.dart';
import '../../../../helpers/responsive_helper.dart';
import '../controllers/language_controller.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          CustomAppbar.appbar(title: MyStrings.language.tr, context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: TranslationsService.languageList.map((language) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    Text(language.imageUrl,
                        style: TextStyle(
                            fontSize: ResponsiveHelper.isTab(context)
                                ? 16.sp
                                : 20.sp)),
                    const SizedBox(width: 5),
                    Text(
                      language.languageCode == "ar"
                          ? MyStrings.arabic.toString().capitalizeFirst.toString()
                          : language.languageCode == "it"
                              ? MyStrings.italian.toString().capitalizeFirst.toString()
                              : MyStrings.english.toString().capitalizeFirst.toString(),
                      style: ResponsiveHelper.isTab(context)
                          ? MyColors.l5C5C5C_dwhite(context).medium13
                          : MyColors.l5C5C5C_dwhite(context).medium17,
                    ),
                  ],
                ),
                value: language.languageCode,
                groupValue: Get.locale?.languageCode ?? "en",
                onChanged: (value) {
                  Get.updateLocale(Locale(value!));
                  StorageHelper.setLanguage = value;
                },
                activeColor: MyColors.c_C6A34F,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
