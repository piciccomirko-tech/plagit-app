import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_plagit_plus/controllers/employee_plagit_plus_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeePlagitPlusView extends GetView<EmployeePlagitPlusController> {
  const EmployeePlagitPlusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: CustomAppbar.appbar(
  context: context,
  isPlagItPlus: false,
  title: "${MyStrings.plagIt.tr} + ",
  centerTitle: false,
  visibleBack: false,
  actions: [
    const SizedBox(width: 10),
    Obx(() => Get.find<EmployeeHomeController>().notificationsController.unreadCount.value == 0
        ? InkResponse(onTap: () => Get.toNamed(Routes.notifications), child:  Image.asset(MyAssets.bell, height: Get.width>600?30:24, width: Get.width>600?30:24)
    )
        : InkResponse(
      onTap: () => Get.toNamed(Routes.notifications),
      child: Badge(
          backgroundColor: MyColors.c_C6A34F,
          label: Obx(() {
            return Text(
                Get.find<EmployeeHomeController>().notificationsController.unreadCount.value == 20
                    ? '20+'
                    : Get.find<EmployeeHomeController>().notificationsController.unreadCount.toString(),
                style:  TextStyle(fontSize: Get.width>600?13:12, color: MyColors.white));
          }),
          child:  Image.asset(MyAssets.bell, height: Get.width>600?30:24, width: Get.width>600?30:24)
        // Icon(CupertinoIcons.bell, size: Get.width>600?30:21),
      ),
    )
    ),
    /* const SizedBox(width: 20),
              InkResponse(
                onTap: () => Get.toNamed(Routes.notifications),
                child: Badge(
                    backgroundColor: MyColors.c_C6A34F,
                    label: Obx(() {
                      return Text(
                          controller.notificationsController.unreadCount.value == 20
                              ? '20+'
                              : controller.notificationsController.unreadCount.toString(),
                          style:  TextStyle(fontSize: Get.width>600?13:12, color: MyColors.white));
                    }),
                    child:  Image.asset(MyAssets.chat, height: Get.width>600?30:21, width: Get.width>600?30:21,)
                  // Icon(CupertinoIcons.bell, size: Get.width>600?30:21),
                ),
              ),*/
    const SizedBox(width: 30),
    InkWell(
        onTap: ()=>Get.toNamed(Routes.employeePlagitPlus),
        child: Image.asset(MyAssets.logo, height: 45.w, width: 45.w)),
    const SizedBox(width: 10)
  ],
),
      body:  SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( MyStrings.allCoupons.tr, style: MyColors.l111111_dwhite(context).semiBold15),
                  Row(
                    children: [
                       CircleAvatar(
                        backgroundColor: MyColors.lightGrey,
                        radius: 16,
                        child: CircleAvatar(
                          radius: 15,
                            backgroundColor: MyColors.lightCard(context), child: const Icon(Icons.arrow_back_ios_new, size: 18, color: MyColors.lightGrey)),
                      ),
                      SizedBox(width: 15.w),
                      const CircleAvatar(
                        radius: 15,
                          backgroundColor: MyColors.primaryLight, child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: MyColors.white)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Image.asset(MyAssets.couponImage, fit: BoxFit.cover),
              SizedBox(height: 20.h),
              Image.asset(MyAssets.offerImage, fit: BoxFit.cover),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(MyStrings.allEvents.tr , style: MyColors.l111111_dwhite(context).semiBold15),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: MyColors.lightGrey,
                        radius: 16,
                        child: CircleAvatar(
                            radius: 15,
                            backgroundColor: MyColors.lightCard(context), child: const Icon(Icons.arrow_back_ios_new, size: 18, color: MyColors.lightGrey)),
                      ),
                      SizedBox(width: 15.w),
                      const CircleAvatar(
                          radius: 15,
                          backgroundColor: MyColors.primaryLight, child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: MyColors.white)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              SizedBox(
                height: Get.height*0.35,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Image.asset(MyAssets.even1),
                    SizedBox(width: 15.w),
                    Image.asset(MyAssets.event2),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

            ],
          ),
        ),
      ),
    );
  }
}
