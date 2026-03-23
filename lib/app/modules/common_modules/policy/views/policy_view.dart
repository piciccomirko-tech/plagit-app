import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import '../controllers/policy_controller.dart';

class PolicyView extends GetView<PolicyController> {
  const PolicyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(title: MyStrings.policy.tr, context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomRadioButton(
                  autoWidth: true,
                  buttonTextStyle: ButtonTextStyle(
                      unSelectedColor: MyColors.l111111_dwhite(context),
                      textStyle:
                          TextStyle(fontSize: Get.width > 600 ? 18 : null)),
                  shapeRadius: 5,
                  elevation: 0.0,
                  height: 45.h,
                  defaultSelected: 1,
                  enableShape: true,
                  selectedBorderColor: Colors.transparent,
                  unSelectedBorderColor: Colors.transparent,
                  buttonLables: controller.policyLabels,
                  buttonValues: controller.policyValue,
                  radioButtonValue: controller.onButtonTapped,
                  unSelectedColor: MyColors.c_C6A34F.withOpacity(0.2),
                  selectedColor: MyColors.c_C6A34F),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0.sp),
                child: Obx(() => HtmlWidget(buildAsync: false,
                        customStylesBuilder: (element) {
                      if ((element.localName == "h2") && (Get.width > 600)) {
                        return {"font-style": "bold", "font-size:": "25px"};
                      } else if ((element.localName == "h2") &&
                          (Get.width <= 600)) {
                        return {"font-style": "bold"};
                      } else if ((element.localName == "p" ||
                              element.localName == "ul" ||
                              element.localName == "li" ||
                              element.localName == "ol") &&
                          (Get.width > 600)) {
                        return {"font-size": "20px"};
                      } else if ((element.localName == "p" ||
                              element.localName == "ul" ||
                              element.localName == "li" ||
                              element.localName == "ol") &&
                          (Get.width <= 600)) {
                        return {"font-size": "15px"};
                      }
                    }, controller.policyText.value.toString())),
              )
            ],
          ),
        ),
      ),
    );
  }
}
