import '../utils/exports.dart';

class CustomBottomBar extends StatelessWidget {
  final Widget child;

  const CustomBottomBar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92.h,
      decoration: BoxDecoration(
        border: Border.all(
          width: .5,
          color: MyColors.c_A6A6A6,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        color: MyColors.lightCard(context),
      ),
      child: Align(
        child: child,
      ),
    );
  }
}
