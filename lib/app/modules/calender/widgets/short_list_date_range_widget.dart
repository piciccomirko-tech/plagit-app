import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/calender/widgets/short_list_time_range_widget.dart';

class ShortListDateRangeWidget extends GetWidget<CalenderController> {
  const ShortListDateRangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: controller.requestDateList.isNotEmpty,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controller.requestDateList.length,
                (int index) => ShortListTimeRangeWidget(requestDate: controller.requestDateList[index], index: index)),
          ),
        )));
  }
}
