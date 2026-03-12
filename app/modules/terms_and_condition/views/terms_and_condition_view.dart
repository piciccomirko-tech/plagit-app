import 'package:flutter/cupertino.dart';

import '../../../common/utils/exports.dart';
import '../../../common/widgets/custom_appbar.dart';
import '../../client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import '../controllers/terms_and_condition_controller.dart';

class TermsAndConditionView extends GetView<TermsAndConditionController> {
  const TermsAndConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.lFAFAFA_dframeBg(context),
      appBar: CustomAppbar.appbar(
        title: MyStrings.termsConditions.tr,
        context: context,
      ),
      body: controller.obx(
            (state) => ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 25.h),
          itemCount: (state?.termsConditions ?? []).length,
          itemBuilder: (context, index) {
            return _item(context, state!.termsConditions![index]);
          },
        ),
        onLoading: const Center(child: CupertinoActivityIndicator(
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
                  )
              ),
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
