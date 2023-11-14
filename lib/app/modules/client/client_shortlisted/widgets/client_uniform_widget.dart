import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/modules/client/client_shortlisted/controllers/client_shortlisted_controller.dart';

class ClientUniformWidget extends StatelessWidget {
  final ClientShortlistedController clientShortlistedController = Get.find<ClientShortlistedController>();
  ClientUniformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
            child: Column(children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomAppbarBackButton(),
                  Text('Select Uniform', style: MyColors.l111111_dwhite(context).semiBold20),
                  const Wrap()
                ],
              ),
              const SizedBox(height: 10),
              const Text('Do you need employees to have uniform'),
              const SizedBox(height: 5),
              const Text('from us?'),
              const SizedBox(height: 20),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text('Yes, Definitely needed', style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      const Text(
                          'In case if you need any uniform from us for employees, different uniforms for different post (eg: chef, waiter)',
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: clientShortlistedController.onViewUniformClick,
                        child: const Text(
                          'View Uniform',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: MyColors.c_C6A34F,
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: 'Yes',
                  groupValue: clientShortlistedController.selectedOption.value,
                  onChanged: clientShortlistedController.onUniformChange,
                ),
              ),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text('No need', style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle: const Column(
                    children: [
                      SizedBox(height: 5),
                      Text(
                          "In case if you don't need any uniform from us, or you have your own uniform for the employees",
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  value: 'No',
                  groupValue: clientShortlistedController.selectedOption.value,
                  onChanged: clientShortlistedController.onUniformChange,
                ),
              ),
            ])));
  }
}
