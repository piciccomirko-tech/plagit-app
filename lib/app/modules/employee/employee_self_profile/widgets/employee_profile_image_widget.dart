import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/employee/employee_self_profile/controllers/employee_self_profile_controller.dart';

class EmployeeProfileImageWidget extends GetWidget<EmployeeSelfProfileController> {
  const EmployeeProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Container(
          width: 150.h,
          height: 150.h,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2.5,
                color: MyColors.c_C6A34F,
              )),
          child: Obx(
                () => CustomNetworkImage(
              url: (controller.employee.value.details?.profilePicture ?? "").imageUrl,
              radius: 130,
            ),
          ),
        ),
        /*InkResponse(
          onTap: () => controller.showImagePickerBottomSheet(context),
          child: Stack(
            children: [
              Container(
                width: 150.h,
                height: 150.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2.5,
                      color: MyColors.c_C6A34F,
                    )),
                child: Obx(
                  () => CustomNetworkImage(
                    url: (controller.employee.value.details?.profilePicture ?? "").imageUrl,
                    radius: 130,
                  ),
                ),
              ),
              Positioned.fill(
                  child: Align(alignment: Alignment.bottomCenter, child: Image.asset(MyAssets.intersect, width: 90))),
              Positioned.fill(
                  bottom: 5,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(MyAssets.camera, width: 30, height: 30, color: MyColors.white))),
            ],
          ),
        ),*/
        const Spacer(),
      ],
    );
  }
}
