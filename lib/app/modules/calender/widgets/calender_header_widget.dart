import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/widgets/calender_status_widget.dart';

class CalenderHeaderWidget extends StatelessWidget {
  const CalenderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(backgroundColor: Colors.blue, title: MyStrings.unavailable.tr),
            const SizedBox(height: 10),
            CalenderStatusWidget(backgroundColor: Colors.red, title: MyStrings.booked.tr)
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(
              backgroundColor: Colors.green,
              title: MyStrings.available.tr,
            ),
            const SizedBox(height: 10),
            CalenderStatusWidget(
              backgroundColor: Colors.amber,
              title: MyStrings.pending.tr,
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(backgroundColor: MyColors.c_C6A34F, title: MyStrings.selected.tr),
            const SizedBox(height: 10),
            CalenderStatusWidget(backgroundColor: Colors.grey, title: MyStrings.disabled.tr)
          ],
        ),
      ],
    );
  }
}
