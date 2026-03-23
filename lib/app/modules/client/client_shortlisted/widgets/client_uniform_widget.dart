import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/modules/client/client_shortlisted/controllers/client_shortlisted_controller.dart';
import '../../../../common/utils/exports.dart';

class ClientUniformWidget extends StatelessWidget {
  final ClientShortlistedController clientShortlistedController = Get.find<ClientShortlistedController>();
  ClientUniformWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
            child: Column(children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomAppbarBackButton(),
                  Text(MyStrings.uniformProvided.tr, style: MyColors.l111111_dwhite(context).semiBold20),
                  const Wrap()
                ],
              ),
              const SizedBox(height: 10),
               Text(MyStrings.willYouProvideUniform.tr, style: MyColors.l111111_dwhite(context).medium15),
              const SizedBox(height: 5),
               Text('${MyStrings.employee.tr}s?', style: MyColors.l111111_dwhite(context).medium15),
              const SizedBox(height: 20),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text(MyStrings.yesWeWill.tr, style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                       Text(
                          MyStrings.weWillProvideDifferentUniforms.tr,
                          style: MyColors.l111111_dwhite(context).medium13),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: clientShortlistedController.onViewUniformClick,
                        child:  Text(
                          MyStrings.viewSampleUniform.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: Get.width>600? 12.sp:null,
                            color: MyColors.c_C6A34F,
                          ),
                        ),
                      ),
                    ],
                  ),
                  value: 'Yes',
                  groupValue: clientShortlistedController.selectedOption.value,
                  onChanged: clientShortlistedController.onUniformChange,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => RadioListTile(
                  activeColor: MyColors.c_C6A34F,
                  title: Text(MyStrings.noWeDont.tr, style: MyColors.l111111_dwhite(context).semiBold18),
                  subtitle:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(
                          MyStrings.noUniformsProvided.tr,
                          style: MyColors.l111111_dwhite(context).medium13),
                      const SizedBox(height: 5),
                      Text(
                          MyStrings.notMandatory.tr,
                          style: MyColors.l111111_dwhite(context).medium13),
                    ],
                  ),
                  value: 'No',
                  groupValue: clientShortlistedController.selectedOption.value,
                  onChanged: clientShortlistedController.onUniformChange,
                ),
              ),
            ])));
  }
}
