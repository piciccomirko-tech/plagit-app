import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/card_add_controller.dart';

class CardAddView extends GetView<CardAddController> {
  const CardAddView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
        appBar: CustomAppbar.appbar(
          title: "Add Card",
          context: context,
        ),
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: MyColors.c_C6A34F,
            onPressed: controller.onCloseTapped,
            label: Text(MyStrings.close.tr, style: MyColors.white.semiBold16)),
        body: Obx(() => controller.sessionIdLoading.value == true
            ? Center(child: CustomLoader.loading())
            : Stack(
                children: <Widget>[
                  WebViewWidget(controller: controller.webViewController),
                  controller.isLoading.value == true ? const Center(child: CupertinoActivityIndicator()) : const Wrap(),
                ],
              )));
  }
}
