import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_plan_response_model.dart';

class SubscriptionWidget extends StatelessWidget {
  final SubscriptionPlanModel subscriptionPlan;
  final VoidCallback onTap;
  final String module;
  const SubscriptionWidget(
      {super.key,
      required this.subscriptionPlan,
      required this.onTap,
      required this.module});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.25),
          color: MyColors.lightCard(context)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(MyAssets.subscription, height: 43.w, width: 43.w),
              SizedBox(height: 20.w),
              Text("${MyStrings.plagIt.tr} + ",
                  style:  TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 34, color: MyColors.l111111_dwhite(context))),
              SizedBox(height: 10.w),
              Text(MyStrings.unleashThePowerOfYourService.tr,
                  style: MyColors.subscriptionTextColor.regular17),
              Text(MyStrings.withProPlan.tr,
                  style: MyColors.subscriptionTextColor.regular17),
              SizedBox(height: 10.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      "${Utils.getCurrencySymbol()}${Utils.getSubscriptionMonthlyCharge(subscriptionPlan: subscriptionPlan)}",
                      style:  TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30, color: MyColors.l111111_dwhite(context))),
                  Text(MyStrings.perMonth.tr,
                      style: MyColors.subscriptionTextColor.regular17),
                ],
              ),
              Text(
                  "${Utils.getCurrencySymbol()}${Utils.getActualSubscriptionMonthlyCharge(subscription: subscriptionPlan)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                      color: MyColors.subscriptionTextColor,
                      decoration: TextDecoration.lineThrough)),
              if (Utils.getDiscountText(subscription: subscriptionPlan)
                  .isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: MyColors.primaryLight),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(MyAssets.discount, height: 24.w, width: 24.w),
                      Text(
                          "  ${Utils.getDiscountText(subscription: subscriptionPlan)}",
                          style: MyColors.white.regular18),
                    ],
                  ),
                ),
              const Divider(
                  color: MyColors.lightGrey,
                  thickness: 0.3,
                  endIndent: 5,
                  indent: 5),
              const SizedBox(height: 10),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                    itemCount: (subscriptionPlan.keys ?? []).length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String key = (subscriptionPlan.keys ?? [])[index];
                      return Row(
                        children: [
                          Image.asset(MyAssets.checkMark,
                              height: 21, width: 21, color: MyColors.l111111_dwhite(context)),
                          Text("  $key",
                              style:
                                  MyColors.l111111_dwhite(context).regular18),
                        ],
                      );
                    }),
              ),
              const SizedBox(height: 30),
              CustomButtons.button(
                  margin: EdgeInsets.zero,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  text: MyStrings.getStarted.tr,
                  onTap: onTap),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
