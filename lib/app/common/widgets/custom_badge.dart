import '../utils/exports.dart';

class CustomBadge extends StatelessWidget {
  final String text;

  const CustomBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration:  BoxDecoration(
        shape: BoxShape.circle,
        color: MyColors.c_00C92C,
      ),
      child: Text(
        text,
        style: MyColors.white.semiBold15,
      ),
    );
  }
}
