import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/routes/app_pages.dart';

class StripePaymentSuccessView extends StatelessWidget {
  const StripePaymentSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset('assets/lottie/payment_success.json', height: 250, width: 250),
               Text(MyStrings.paymentSucessText, style: MyColors.l111111_dwhite(Get.context!).semiBold20),
               SizedBox(height: Get.width*0.4),
              CustomButtons.button(
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                text: 'BACK TO HOME',
                onTap: () {
                  Get.offAllNamed(Routes.clientHome);
                },
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
