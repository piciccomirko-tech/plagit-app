import 'package:mh/app/common/utils/exports.dart';

class CalenderStatusWidget extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  const CalenderStatusWidget({super.key, required this.backgroundColor, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [CircleAvatar(backgroundColor: backgroundColor, radius: 8),
        const SizedBox(width: 10),
        Text(title, style: MyColors.l111111_dwhite(context).medium13)],
    );
  }
}
