import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_tab_widget.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';

class AdminHomeTabWidget extends GetWidget<AdminHomeController> {
  const AdminHomeTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: MyColors.lightCard(context),
        border: Border.all(color: MyColors.noColor, width: 0.5),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: controller.tabs
            .asMap()
            .entries
            .map(
              (entry) => CustomTabWidget(
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
