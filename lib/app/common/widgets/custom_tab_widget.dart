import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';

import '../../helpers/responsive_helper.dart';

class CustomTabWidget extends StatelessWidget {
  final BuildContext context;
  final HomeTabModel model;
  final int index;
  final VoidCallback onTap;
  final String module;

  const CustomTabWidget({
    super.key,
    required this.module,
    required this.context,
    required this.model,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return (model.titleKey.tr).length>12?Flexible(
      child: GestureDetector(
      onTap: onTap,
      child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: module == 'client' ? 30.0.w : 10.0.w,
              vertical: 10.0.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              gradient: model.isSelected
                  ? Utils.primaryGradient
                  : Utils.transparentGradient,
            ),
            child: Stack(
              clipBehavior: Clip.none, // Allows the red dot to overflow if needed
              children: [
                Text(
                  model.titleKey.tr,
                  style: (model.isSelected
                      ? MyColors.white.semiBold14
                      : MyColors.l111111_dwhite(context).semiBold14).copyWith(
                    fontSize: 15.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Positioned(
                  top: -4.0,
                  right: -10.0,
                  child: model.hasUpdate
                      ? Container(
                    width: 8.0.w,
                    height: 8.0.w,
                    decoration: BoxDecoration(
                      color: model.isSelected ? Colors.white : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                      : SizedBox(
                    width: 8.0.w,
                    height: 8.0.w,
                  ),
                ),
              ],
            ),
        ),
      ),
      ):
    GestureDetector(
        onTap: onTap,
        child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: module == 'client' ? 20.0.w : 30.0.w,
          vertical: 10.0.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          gradient: model.isSelected
              ? Utils.primaryGradient
              : Utils.transparentGradient,
        ),
        child: Stack(
          clipBehavior: Clip.none, // Allows the red dot to overflow if needed
          children: [
            Text(
              model.titleKey.tr,
              style: (model.isSelected
                  ? MyColors.white.semiBold14
                  : MyColors.l111111_dwhite(context).semiBold14).copyWith(
                fontSize: ResponsiveHelper.isTab(context)?10.sp:15.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Positioned(
              top: -4.0,
              right: -10.0,
              child: model.hasUpdate
                  ? Container(
                width: 8.0.w,
                height: 8.0.w,
                decoration: BoxDecoration(
                  color: model.isSelected ? Colors.white : Colors.red,
                  shape: BoxShape.circle,
                ),
              )
                  : SizedBox(
                width: 8.0.w,
                height: 8.0.w,
              ),
            ),
          ],
        ),
            ),
      );
  }
}
