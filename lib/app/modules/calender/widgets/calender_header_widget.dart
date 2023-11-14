import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/widgets/calender_status_widget.dart';

class CalenderHeaderWidget extends StatelessWidget {
  const CalenderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(backgroundColor: Colors.blue, title: 'Unavailable'),
            SizedBox(height: 10),
            CalenderStatusWidget(backgroundColor: Colors.red, title: 'Booked')
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(
              backgroundColor: Colors.green,
              title: 'Available',
            ),
            SizedBox(height: 10),
            CalenderStatusWidget(
              backgroundColor: Colors.amber,
              title: 'Pending',
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalenderStatusWidget(backgroundColor: MyColors.c_C6A34F, title: 'Selected'),
            SizedBox(height: 10),
            CalenderStatusWidget(backgroundColor: Colors.grey, title: 'Disabled')
          ],
        ),
      ],
    );
  }
}
