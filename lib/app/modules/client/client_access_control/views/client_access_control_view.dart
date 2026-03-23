import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/client_access_control/controllers/client_access_control_controller.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../../../../helpers/responsive_helper.dart';

class ClientAccessControlView extends GetView<ClientAccessControlController> {
  const ClientAccessControlView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppbar.appbar(
            title: MyStrings.accessControl.tr,
            context: context,
            centerTitle: true),
        body: controller.isLoading.value
            ? Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 0.h, left: 15.w, right: 15.w),
                  child:
                      ShimmerWidget.clientMyEmployeesShimmerWidget(height: 130),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(15.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.myAlterUsers.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        itemCount: controller.myAlterUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          var user = controller.myAlterUsers[index];
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
                              title: Text(
                                user.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Get.width > 600
                                    ? MyColors.l111111_dwhite(Get.context!)
                                        .regular18
                                    : MyColors.l111111_dwhite(Get.context!)
                                        .regular18,
                              ),
                              subtitle: Text(user.email ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.width > 600
                                      ? MyColors.l111111_dwhite(Get.context!)
                                          .regular10
                                      : MyColors.l111111_dwhite(Get.context!)
                                          .regular10),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkResponse(
                                    onTap: () {
                                      controller.nameController.text =
                                          user.name ?? '';
                                      controller.emailController.text =
                                          user.email ?? '';
                                      controller.passwordController.text = "";
                                      showUserForm(index: index);
                                    },
                                    child: CircleAvatar(
                                      radius: 12.sp,
                                      backgroundColor: MyColors.primaryLight,
                                      child: Icon(Icons.edit,
                                          color: MyColors.white, size: 12.sp),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkResponse(
                                    onTap: () => controller.deleteUser(index),
                                    child: CircleAvatar(
                                      radius: 12.sp,
                                      backgroundColor: Colors.red,
                                      child: Icon(CupertinoIcons.delete_solid,
                                          color: MyColors.white, size: 12.sp),
                                    ),
                                  ),
                                  // IconButton(
                                  //   icon: Icon(Icons.edit),
                                  //   onPressed: () {
                                  //     controller.nameController.text =
                                  //         user.name ?? '';
                                  //     controller.emailController.text =
                                  //         user.email ?? '';
                                  //     controller.passwordController.text = "";
                                  //     showUserForm(index: index);
                                  //   },
                                  // ),
                                  // IconButton(
                                  //   icon: Icon(Icons.delete),
                                  //   onPressed: () => controller.deleteUser(index),
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    if (controller.myAlterUsers.length < 2)
                      Center(
                        child: controller.isAdding.value
                            ? CupertinoActivityIndicator()
                            : CustomButtons.button(
                                height: Get.width > 600 ? 30.h : 48.h,
                                fontSize: ResponsiveHelper.isTab(context)
                                    ? 10.sp
                                    : 15.sp,
                                onTap: () => showUserForm(),
                                backgroundColor: MyColors.c_C6A34F,
                                text: MyStrings.addNew.tr,
                                customButtonStyle:
                                    CustomButtonStyle.radiusTopBottomCorner,
                              ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void showUserForm({index}) {
    Get.dialog(
      AlertDialog(
        title: Text(
          index == null ? "Add User" : "Edit User",
          style: Get.width > 600
              ? MyColors.l111111_dwhite(Get.context!).regular24
              : MyColors.l111111_dwhite(Get.context!).regular24,
        ),
        content: Form(
          key: controller.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: Get.width > 600
                    ? MyColors.l111111_dwhite(Get.context!).regular18
                    : MyColors.l111111_dwhite(Get.context!).regular18,
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: MyStrings.name.tr,
                  labelStyle: Get.width > 600
                      ? MyColors.l111111_dwhite(Get.context!).regular18
                      : MyColors.l111111_dwhite(Get.context!).regular18,
                ),
                validator: (value) => value!.trim().isEmpty ? "Required" : null,
              ),
              TextFormField(
                style: Get.width > 600
                    ? MyColors.l111111_dwhite(Get.context!).regular18
                    : MyColors.l111111_dwhite(Get.context!).regular18,
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: MyStrings.email.tr,
                  labelStyle: Get.width > 600
                      ? MyColors.l111111_dwhite(Get.context!).regular18
                      : MyColors.l111111_dwhite(Get.context!).regular18,
                ),
                validator: (String? value) => Validators.emailValidator(
                  value
                ),
              ),
              TextFormField(
                style: Get.width > 600
                    ? MyColors.l111111_dwhite(Get.context!).regular18
                    : MyColors.l111111_dwhite(Get.context!).regular18,
                controller: controller.passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: Get.width > 600
                      ? MyColors.l111111_dwhite(Get.context!).regular18
                      : MyColors.l111111_dwhite(Get.context!).regular18,
                ),
                obscureText: true,
                validator: (String? value) => Validators.emptyValidator(
                  value,
                  MyStrings.required.tr,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: MyColors.primaryLight.semiBold16,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.addOrUpdateUser(index: index);
            },
            child: Text(
              "Submit",
              style: MyColors.primaryLight.semiBold16,
            ),
          ),
        ],
      ),
    );
  }
}
