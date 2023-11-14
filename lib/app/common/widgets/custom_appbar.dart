import '../utils/exports.dart';
import 'custom_appbar_back_button.dart';

class CustomAppbar {
  static PreferredSize appbar({
    List<Widget>? actions,
    bool centerTitle = false,
    bool visibleBack = true,
    bool visibleMH = false,
    required String title,
    required BuildContext context,
  }) =>
      PreferredSize(
        preferredSize: Size.fromHeight(54.h),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: const Color(0XFF000000).withOpacity(.08),
              offset: Offset(0, 3.h),
              blurRadius: 10.0,
            )
          ]),
          child: AppBar(
            backgroundColor: MyColors.lightCard(context),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
            ),
            elevation: 0,
            leading: visibleBack
                ? const Align(child: CustomAppbarBackButton())
                : Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Image.asset(MyAssets.logo),
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
                    MyStrings.mh.tr,
                    style: MyColors.c_C6A34F.semiBold18,
                  ),
                ),
                Text(
                  title,
                  style: MyColors.l111111_dwhite(context).semiBold18,
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
