import '../utils/exports.dart';

class CustomBadge extends StatelessWidget {
  final String text;

  const CustomBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: MyColors.c_C6A34F,
      ),
      child: Text(
        text,
        style: MyColors.white.medium14,
      ),
    );
  }
}
