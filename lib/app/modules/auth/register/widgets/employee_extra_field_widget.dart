import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/auth/register/controllers/register_controller.dart';
import 'package:mh/app/modules/auth/register/models/employee_extra_field_model.dart';

class EmployeeExtraFieldWidget extends GetWidget<RegisterController> {
  const EmployeeExtraFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 26.h),
        Obx(() => Visibility(
            visible: controller.extraFieldList.isNotEmpty,
            child: ListView.builder(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.zero,
                itemCount: controller.extraFieldList.length,
                itemBuilder: (BuildContext context, int index) {
                  Fields field = controller.extraFieldList[index];
                  return field.disabled == true
                      ? const Wrap()
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 18.w),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(width: .5, color: MyColors.c_777777),
                                color: Theme.of(controller.context!).cardColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf,
                                    color: MyColors.c_7B7B7B,
                                  ),
                                  SizedBox(width: 7.w),
                                  Expanded(
                                    child: Text(
                                      field.label ?? '',
                                      style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      FilePickerResult? result = await FilePicker.platform
                                          .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

                                      if (result != null) {
                                        File file = File(result.files.single.path!);
                                        int size = await file.length();

                                        if (size <= 5 * 1024 * 1024) {
                                          final File file = File(result.files.first.path!);
                                          field.label = file.absolute.path.split('/').last;
                                          controller.extraFieldList.refresh();
                                          await controller.uploadExtraFile(
                                              file: file, fileName: result.files.single.name, label: field.label??'');
                                        } else {
                                          Utils.showSnackBar(
                                              message: 'File size cannot be more than 5MB', isTrue: false);
                                        }
                                      }
                                    },
                                    child: Icon(
                                      field.label!.contains('pdf') ? Icons.cancel : Icons.upload,
                                      color: MyColors.c_7B7B7B,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 26.h)
                          ],
                        );
                }))),
      ],
    );
  }
}
