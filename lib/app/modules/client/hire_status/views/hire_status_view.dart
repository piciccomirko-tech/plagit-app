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
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Lottie.asset(MyAssets.lottie.registrationDone),
                        Text(
                          "Booked Successfully",
                          style: MyColors.l111111_dwhite(context).semiBold22,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Our authority will contact with you within 1 hour",
                          style: MyColors.l111111_dwhite(context).semiBold15,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "for further execution",
                          style: MyColors.l111111_dwhite(context).semiBold15,
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
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MyColors.c_C6A34F,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              CupertinoIcons.home,
                              size: 25,
                              color: MyColors.white,
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "Home",
                              style: MyColors.white.semiBold15,
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
