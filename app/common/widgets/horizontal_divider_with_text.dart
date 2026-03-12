import '../utils/exports.dart';

class HorizontalDividerWithText extends StatelessWidget {
  final String? text;
  final Widget? child;
  final double? thickness;

  const HorizontalDividerWithText({
    super.key,
    this.text,
    this.child,
    this.thickness = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _divider(context)),
        const SizedBox(width: 5),
        child ??
            Text(
              text ?? "",
              style: MyColors.text.semiBold15,
            ),
        const SizedBox(width: 5),
        Expanded(child: _divider(context)),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(
        color: Theme.of(context).dividerColor,
        thickness: thickness,
      );
}
