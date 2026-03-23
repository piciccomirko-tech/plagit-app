import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_tab_widget.dart';
import 'package:mh/app/modules/client/employee_details/controllers/employee_details_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';

class EmployeeDetailsTabWidget extends GetWidget<EmployeeDetailsController> {
  const EmployeeDetailsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(horizontal: 15.0.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
       color: MyColors.lightCard(context),
        border: Border.all(color: MyColors.noColor, width: 0.2),
      ),
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
