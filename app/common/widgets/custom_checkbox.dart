import '../utils/exports.dart';

class CustomCheckBox extends StatelessWidget {
  final bool active;
  final Function(bool value) onChange;

  const CustomCheckBox({
    super.key,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChange(!active);
      },
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.44),
          border: Border.all(color: MyColors.c_C6A34F, width: 2),
          color: active ? MyColors.c_C6A34F : Theme.of(context).cardColor,
        ),
        child: Visibility(
          visible: active,
          child: Center(
            child: Icon(
              Icons.check,
              size: 14,
              color: Theme.of(context).cardColor,
            ),
          ),
        ),
      ),
    );
  }
}
