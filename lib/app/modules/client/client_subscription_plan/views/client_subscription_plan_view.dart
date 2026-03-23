import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../controllers/client_subscription_plan_controller.dart';

class ClientSubscriptionPlanView
    extends GetView<ClientSubscriptionPlanController> {
  const ClientSubscriptionPlanView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.subscriptionPlan.tr,
        context: context,
      ),
      body: Obx(() {
        if (controller.isLoading.value == true) {
          return Padding(
            padding: EdgeInsets.all(15.0.w),
            child: Center(
                child: ShimmerWidget.clientSubscriptionViewShimmerEffectWidget()),
          );
        } else {
          return Center(
            child: CarouselSlider.builder(
              itemCount: controller.packageList.length,
              itemBuilder: (context, index, realIndex) {
                var singlePackage = controller.packageList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: .5,
                      color: MyColors.c_A6A6A6,
                    ),
                    borderRadius: BorderRadius.circular(20.25),
                    color: MyColors.lightCard(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 20.w),
                        Image.asset(MyAssets.subscription,
                            height: 43.w, width: 43.w),
                        SizedBox(height: 20.w),
                        Text("${singlePackage.name}",
                            style: TextStyle(
                                fontFamily: MyAssets.fontKlavika,
                                fontWeight: FontWeight.w500,
                                fontSize: 34,
                                color: MyColors.l111111_dwhite(context))),
                        SizedBox(height: 10.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(Utils.getClientActualSubscriptionMonthlyCharge( subscription:singlePackage)==0.0?'Free':"\$${Utils.getClientActualSubscriptionMonthlyCharge( subscription:singlePackage)}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30,
                                    color: MyColors.l111111_dwhite(context),
                                    fontFamily: MyAssets.fontKlavika)),
                            Text(singlePackage.type=='monthly'?MyStrings.perMonth.tr:singlePackage.type=='yearly'?MyStrings.perYear.tr:MyStrings.forLifetime.tr,
                                style:
                                    MyColors.subscriptionTextColor.regular17),
                          ],
                        ),
                        SizedBox(height: 10.w),
                        const Divider(
                            color: MyColors.lightGrey,
                            thickness: 0.3,
                            endIndent: 5,
                            indent: 5),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                              itemCount: singlePackage.keys!.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                String key = (singlePackage.keys ?? [])[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(MyAssets.checkMark,
                                        height: 21,
                                        width: 21,
                                        color: MyColors.l111111_dwhite(context)),
                                    SizedBox(width: 5,),
                                    Flexible(
                                      child: Text(key,
                                          style: MyColors.l111111_dwhite(context)
                                              .regular18),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        const SizedBox(height: 20),
                        Obx(()=>controller.selectedPlanIndex.value==index&&controller.isUpgradingPlan.value?Container(
                            height: Get.width>600?40.h: 52.w,
                            margin: EdgeInsets.zero,
                            child: CupertinoActivityIndicator(color: MyColors.l111111_dwhite(context),)):
                        Container(
                          height: Get.width>600?40.h: 52.w,
                          margin: EdgeInsets.zero,
                          decoration: BoxDecoration(
                              color: controller.currentSubscriptionPlanId.value==singlePackage.id?Colors.grey:MyColors.primaryLight,
                              gradient: controller.currentSubscriptionPlanId.value==singlePackage.id?null:Utils.primaryGradient,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              )),
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                              onTap: (){
                                if(controller.currentSubscriptionPlanId.value==singlePackage.id) {

                                }else {
                                  controller.selectedPlanIndex.value=index;
                                  controller.upgradePlan();
                                }
                              },
                              child: Center(
                                child: Text(
                                  controller.currentSubscriptionPlanId.value!=singlePackage.id?'Get ${singlePackage.name}':'Your current plan'.capitalize!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: MyAssets.fontKlavika,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                    color: _getTextColor(CustomButtonStyle.regular),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),),
                        const SizedBox(height: 10)
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                initialPage: controller.activeSubscriptionPlanIndex.value,
                height: Get.height - 230,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                viewportFraction: 0.75,
              ),
            ),
          );
        }
      }),
    );
  }
  static Color _getTextColor(CustomButtonStyle customButtonStyle) {
    switch (customButtonStyle) {
      case CustomButtonStyle.outline:
        return MyColors.c_C6A34F;
      case CustomButtonStyle.radiusTopBottomCorner:
      case CustomButtonStyle.regular:
      default:
        return MyColors.white;
    }
  }
}