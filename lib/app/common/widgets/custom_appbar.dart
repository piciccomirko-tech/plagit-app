import 'package:mh/app/common/local_storage/storage_helper.dart';
import '../../helpers/responsive_helper.dart';
import '../utils/exports.dart';
import 'custom_appbar_back_button.dart';

class CustomAppbar {
  static PreferredSize appbar({
    List<Widget>? actions,
    bool centerTitle = false,
    bool visibleBack = true,
    bool visibleMH = false,
    required String title,
    bool? isPlagItPlus,
    double? radius,
    required BuildContext context,
    Future<void> Function()? onRefresh,
    VoidCallback? onBackButtonPressed, // Added callback for the back button
  }) =>
      PreferredSize(
        preferredSize:
            Size.fromHeight(ResponsiveHelper.isTab(Get.context)? 0.07.sw : kToolbarHeight),
        child: Container(
          decoration: radius == 0.0
              ? null
              : BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: const Color(0XFF000000).withOpacity(.08),
                    offset: Offset(0, 3.h),
                    blurRadius: 10.0,
                  )
                ]),
          child: AppBar(
            backgroundColor: MyColors.lightCard(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(radius ?? 10.0),
              ),
            ),
            elevation: 0,
            leading: visibleBack
                ? Align(
                    child: GestureDetector(
                      onTap: () {
                        if (onBackButtonPressed != null) {
                          onBackButtonPressed();
                        }
                        else{
                        Get.back(); // Navigates to the previous screen
                        }
                      },
                      child: CustomAppbarBackButton( onPressed: onBackButtonPressed ?? () => Get.back(),),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.fromLTRB(
                        StorageHelper.getLanguage == "ar" ? 0 : 10,
                        0,
                        StorageHelper.getLanguage == "ar" ? 10 : 0,
                        0),
                    child: (isPlagItPlus ?? false) == true
                        ? Padding(
                            padding: EdgeInsets.only(
                                right: Get.locale?.languageCode == "ar"
                                    ? 10.0.w
                                    : 0.0),
                            child: GestureDetector(
                              onTap: onRefresh,
                              child: Image.asset(
                                MyAssets.logoPlus,
                                height: 30.w,
                                width: 30.w,
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: (){},
                            child: Image.asset(MyAssets.logo)),
                  ),
            title: Row(
              mainAxisAlignment: centerTitle
                  ? MainAxisAlignment.center
                  : (!visibleBack || (actions ?? []).length > 1)
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: visibleMH,
                  child: Text(
                    MyStrings.plagIt.tr,
                    style: ResponsiveHelper.isTab(Get.context)
                        ? MyColors.c_C6A34F.semiBold13
                        : MyColors.c_C6A34F.semiBold18,
                  ),
                ),
                Text(
                  title.tr,
                  style: ResponsiveHelper.isTab(Get.context)
                      ? MyColors.l111111_dwhite(context).semiBold13
                      : MyColors.l111111_dwhite(context).semiBold18,
                ),
              ],
            ),
            actions: actions == null || actions.isEmpty
                ? [SizedBox(width: 16.w)]
                : actions,
          ),
        ),
      );
}
