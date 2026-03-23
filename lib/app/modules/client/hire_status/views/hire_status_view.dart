import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/utils/exports.dart';
import '../controllers/hire_status_controller.dart';

class HireStatusView extends GetView<HireStatusController> {
  const HireStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding:  EdgeInsets.all(13.0.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Lottie.asset(MyAssets.lottie.registrationDone, height: 300.w, width: 300.w),
                        Text(
                          "${MyStrings.booked.tr} ${MyStrings.successfully.tr}",
                          style: MyColors.l111111_dwhite(context).semiBold20,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          MyStrings.ourAuthority.tr,
                          style: MyColors.l111111_dwhite(context).semiBold13,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          MyStrings.forFurther.tr,
                          style: MyColors.l111111_dwhite(context).semiBold13,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: GestureDetector(
                      onTap: Get.back,
                      child: Container(
                        padding: EdgeInsets.all(15.0.sp),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyColors.c_C6A34F,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             Icon(
                              CupertinoIcons.home,
                              size: 24.w,
                              color: MyColors.white,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              MyStrings.home.tr, 
                              style: Get.width>600?MyColors.white.semiBold12:MyColors.white.semiBold15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
