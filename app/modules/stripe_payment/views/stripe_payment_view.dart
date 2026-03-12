import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/stripe_payment_controller.dart';

class StripePaymentView extends GetView<StripePaymentController> {
  const StripePaymentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar.appbar(
          title: MyStrings.stripePayment.tr,
          context: context,
        ),
        body: Obx(() => Stack(
              children: <Widget>[
                WebViewWidget(controller: controller.webViewController),
                controller.isLoading.value == true ? const Center(child: CupertinoActivityIndicator()) : const Wrap(),
              ],
            )));
  }
}
