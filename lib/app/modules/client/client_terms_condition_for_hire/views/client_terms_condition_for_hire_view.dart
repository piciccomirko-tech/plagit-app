import 'package:flutter/cupertino.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/client_terms_condition_for_hire_controller.dart';
import '../models/terms_condition_for_hire.dart';

class ClientTermsConditionForHireView extends GetView<ClientTermsConditionForHireController> {
  const ClientTermsConditionForHireView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      backgroundColor: MyColors.lFAFAFA_dframeBg(context),
      appBar: CustomAppbar.appbar(
        title: MyStrings.termsConditions.tr,
        context: context,
      ),
      bottomNavigationBar: _bottomBar(context),
      body: controller.obx(
        (state) => ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 25.h),
          itemCount: (state?.termsConditions ?? []).length,
          itemBuilder: (context, index) {
            return _item(context, state!.termsConditions![index]);
          },
        ),
        onLoading: const Center(
            child: CupertinoActivityIndicator(
          radius: 10,
        )),
        onError: (String? msg) => Center(
          child: Text(
            msg ?? "Something wrong!",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return controller.obx(
      (state) => CustomBottomBar(
        child: CustomButtons.button(
          onTap: controller.onIAgreeClick,
          text: "I Agree",
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
        ),
      ),
      onLoading: CustomBottomBar(
        child: CustomButtons.button(
          onTap: null,
          text: "I Agree",
          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
        ),
      ),
    );
  }

  Widget _item(BuildContext context, TermsCondition termsCondition) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 24.w),
            Container(
              height: 27.w,
              width: 27.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: MyColors.lA6A6A6_dstock(context),
                    width: .5,
                  )),
              child: Align(
                child: Container(
                  height: 13.w,
                  width: 13.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: MyColors.c_C6A34F,
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                termsCondition.description ?? "-",
                textAlign: TextAlign.justify,
                style: MyColors.l111111_dwhite(context).semiBold15,
              ),
            ),
            SizedBox(width: 24.w),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}
