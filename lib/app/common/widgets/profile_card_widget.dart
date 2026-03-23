import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/helpers/responsive_helper.dart';

class ProfileCardWidget extends StatelessWidget {
  final String title;
  final String iconPath;
  final IconData? icon;
  final Widget trailing;
  const ProfileCardWidget(
      {super.key,
      required this.trailing,
      required this.title,
      this.iconPath = "",
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      margin: EdgeInsets.only(top: 10.0.h),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: MyColors.noColor,
            width: 0.3,
          ),
          color: MyColors.lightCard(context)),
      child: ListTile(
        leading: iconPath.isNotEmpty
            ? Image.asset(iconPath, height: 38.w, width: 38.w)
            : icon != null
                ? Container(
                    height: 38.w,
                    width: 38.w,
                    decoration: BoxDecoration(
                      color: MyColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 20.r,
                      color: MyColors.white,
                    ),
                  )
                : Offstage(),
        title: Text(title, style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).regular10: MyColors.l111111_dwhite(context).regular14),
        trailing: trailing,
      ),
    );
  }
}
