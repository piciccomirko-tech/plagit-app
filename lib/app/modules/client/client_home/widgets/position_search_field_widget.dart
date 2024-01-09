import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';

class PositionSearchFieldWidget extends GetWidget<ClientHomeController> {
  const PositionSearchFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyDecoration.cardBoxDecoration(context: context),
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: TextFormField(
          cursorColor: MyColors.c_C6A34F,
          style: MyColors.l111111_dwhite(context).medium15,
          controller: controller.tecSearch,
          autofocus: false,
          decoration: InputDecoration(
              suffixIcon: Obx(() => Visibility(
                  visible: controller.showClearIcon.value == true,
                  child: InkWell(
                    onTap: controller.clearIconTap,
                      child: const Icon(CupertinoIcons.clear, color: Colors.red, size: 18)))),
              prefixIcon: const Icon(CupertinoIcons.search, color: MyColors.c_C6A34F),
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
              contentPadding: const EdgeInsets.all(15.0),
              border: InputBorder.none,
              hintText: 'Search by position name...',
              hintStyle: MyColors.c_7B7B7B.medium15),
          onChanged: controller.onSearchChanged,
        ),
      ),
    );
  }
}
