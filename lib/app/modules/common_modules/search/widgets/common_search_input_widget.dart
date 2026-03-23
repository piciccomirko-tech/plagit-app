import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';

import '../../../../helpers/responsive_helper.dart';
import '../controllers/common_search_controller.dart';

class CommonSearchInputWidget extends GetWidget<CommonSearchController> {
  const CommonSearchInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyDecoration.cardBoxDecoration(context: context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: TextFormField(
          cursorColor: MyColors.c_C6A34F,
          style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium10:MyColors.l111111_dwhite(context).medium15,
          controller: controller.searchController,
          autofocus: false,
          decoration: InputDecoration(
              suffixIcon: Obx(() => Visibility(
                  visible: controller.showClearIcon.value == true,
                  child: InkWell(
                      onTap: controller.clearIconTap,
                      child: const Icon(CupertinoIcons.clear,
                          color: Colors.red, size: 18)))),
              prefixIcon:
                  const Icon(CupertinoIcons.search, color: MyColors.c_C6A34F),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: MyColors.lightCard(context),
              contentPadding: EdgeInsets.all(ResponsiveHelper.isTab(context)?5.sp:15.0.sp),
              border: InputBorder.none,
              hintText: MyStrings.commonSearchHint.tr,
              hintStyle: ResponsiveHelper.isTab(context)
                  ? MyColors.c_7B7B7B.medium10
                  : MyColors.c_7B7B7B.medium17),
          onChanged: (value) {
            if (value.isNotEmpty) {
              controller.showClearIcon.value = true;
            } else {
              controller.showClearIcon.value = false;
            }
            controller.performSearch(); // Call performSearch on text change
          },
        ),
      ),
    );
  }
}
