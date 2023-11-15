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
                  Text('Uniform Provided?', style: MyColors.l111111_dwhite(context).semiBold20),
                  const Wrap()
                ],
              ),
              const SizedBox(height: 10),
              const Text('Will you provide uniform to the'),
              const SizedBox(height: 5),
              const Text('employees?'),
              const SizedBox(height: 20),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text('Yes, we will', style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                       Text(
                          'We will provide different uniforms for our employees',
                          style: MyColors.l111111_dwhite(context).medium13),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: clientShortlistedController.onViewUniformClick,
                        child: const Text(
                          'View Sample Uniform',
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
              const SizedBox(height: 10),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text("No, we don't", style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                          "We will not provide any uniforms for our employees.",
                          style: MyColors.l111111_dwhite(context).medium13),
                      const SizedBox(height: 5),
                      Text(
                          "It's not mandatory",
                          style: MyColors.l111111_dwhite(context).medium13),
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
