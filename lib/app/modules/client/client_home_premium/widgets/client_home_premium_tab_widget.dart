import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_tab_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';

class ClientHomePremiumTabWidget extends GetWidget<ClientHomePremiumController> {
  const ClientHomePremiumTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: MyColors.lightCard(context),
        border: Border.all(color: MyColors.noColor, width: 0.2),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.tabs
            .asMap()
            .entries
            .map(
              (MapEntry<int, HomeTabModel> entry) => CustomTabWidget(
            context: context,
            module: 'client',
            model: entry.value,
            index: entry.key,
            onTap: () => controller.selectTab(entry.key),
          ),
        )
            .toList(),
      )),
    );
  }
}
