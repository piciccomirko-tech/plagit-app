import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/common/widgets/custom_feature_box.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class ClientHomeItemsWidget extends GetWidget<ClientHomeController> {
  const ClientHomeItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.jobPostDataLoading.value == true
        ? ShimmerWidget.clientHomeShimmerWidget()
        : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomFeatureBox(
                      height: 0.3.sw,
                      iconHeight: 50.h,
                      title: MyStrings.employees.tr,
                      icon: MyAssets.mhEmployees,
                      visibleMH: true,
                      onTap: controller.onMhEmployeeClick,
                    ),
                  ),
                  SizedBox(width: 0.04.sw),
                  Expanded(
                    child: CustomFeatureBox(
                      height: 0.3.sw,
                      iconHeight: 50.h,
                      title: MyStrings.dashboard.tr,
                      icon: MyAssets.dashboard,
                      onTap: controller.onDashboardClick,
                    )
                  ),
                ],
              ),
              SizedBox(height: 0.02.sh),
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        CustomFeatureBox(
                          height: 0.3.sw,
                          iconHeight: 50.h,
                          title: MyStrings.myEmployees.tr,
                          icon: MyAssets.myEmployees,
                          onTap: controller.onMyEmployeeClick,
                        ),
                        Obx(() => Stack(
                              children: [
                                CustomFeatureBox(
                                  height: 0.3.sw,
                                  iconHeight: 50.h,
                                  title: MyStrings.myEmployees.tr,
                                  icon: MyAssets.myEmployees,
                                  loading: controller.unreadMessageFromEmployeeLoading.value,
                                  onTap: controller.onMyEmployeeClick,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 5,
                                  child: Visibility(
                                    visible: controller.unreadMessageFromEmployee.value > 0,
                                    child: CustomBadge(controller.unreadMessageFromEmployee.value.toString()),
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                  SizedBox(width: 0.04.sw),
                  Expanded(
                    child: Obx(
                      () => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomFeatureBox(
                            height: 0.3.sw,
                            iconHeight: 0.05.sh,
                            title: MyStrings.invoicePayment.tr,
                            icon: MyAssets.invoicePayment,
                            onTap: controller.onInvoiceAndPaymentClick,
                          ),
                          Positioned(
                            top: 4,
                            right: 5,
                            child: Visibility(
                              visible: ((controller.clientPaymentInvoice.value.checkInCheckOutHistory ?? [])
                                  .where((element) => element.status == "DUE")).isNotEmpty,
                              child: CustomBadge(((controller.clientPaymentInvoice.value.checkInCheckOutHistory ?? [])
                                  .where((element) => element.status == "DUE")).length.toString()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.02.sh),
              Row(
                children: [
                  Expanded(
                    child: CustomFeatureBox(
                      height: 0.3.sw,
                      iconHeight: 50.h,
                      title: MyStrings.createJobPost.tr,
                      icon: MyAssets.createPost,
                      onTap: controller.onCreateJobPostClick,
                    ),
                  ),
                  SizedBox(width: 0.04.sw),
                  Expanded(
                      child: Obx(() => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CustomFeatureBox(
                                height: 0.3.sw,
                                iconHeight: 50.h,
                                title: MyStrings.jobRequests.tr,
                                icon: MyAssets.jobRequest,
                                onTap: controller.onJobRequestsClick,
                              ),
                              Positioned(
                                top: 4,
                                right: 5,
                                child: Visibility(
                                  visible: (controller.jobPostRequest.value.jobs ?? []).isNotEmpty,
                                  child: CustomBadge((controller.jobPostRequest.value.jobs ?? []).length.toString()),
                                ),
                              ),
                            ],
                          ))),
                ],
              ),
              SizedBox(height: 0.02.sh),
              Row(
                children: [
                  Expanded(
                    child: CustomFeatureBox(
                      height: 0.3.sw,
                      iconHeight: 50.h,
                      title: 'Social Feed',
                      icon: MyAssets.createPost,
                      onTap: () => Get.toNamed(Routes.socialFeed),
                    ),
                  ),
                  SizedBox(width: 0.04.sw),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ));
  }
}
