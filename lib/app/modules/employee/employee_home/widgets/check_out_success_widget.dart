import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/routes/app_pages.dart';

class CheckOutSuccessWidget extends StatelessWidget {
  const CheckOutSuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.4,
      decoration: BoxDecoration(
        color: MyColors.lightCard(context),
        borderRadius: BorderRadius.circular(20.0)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Lottie.asset(MyAssets.lottie.successLottie, height: 140.w, width: 140.w),
            Text('Checkout Successful', style: MyColors.l111111_dwhite(context).semiBold16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButtons.button(
                    padding: EdgeInsets.symmetric(horizontal: 40.0.w),
                    margin: EdgeInsets.zero,
                    height: 38,
                    fontSize: 15,
                    backgroundColor: Colors.grey.shade400,
                    text: 'Close', onTap: () => Get.back(), customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                CustomButtons.button(
                  height: 38,
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                  margin: EdgeInsets.zero,
                    text: 'Dashboard',
                    fontSize: 15,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    onTap: () => Get.toNamed(Routes.employeeDashboard)!.then((value){
                      Get.back();
                    }))
              ],
            )
          ],
        ),
      ),
    );
  }
}
