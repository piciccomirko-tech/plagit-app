import '../style/my_decoration.dart';
import '../utils/exports.dart';

class CustomDropdown extends StatelessWidget {
  final IconData? prefixIcon;
  final String? hints;
  final String? value;
  final List<String> items;
  final Function(String? item) onChange;
  final String? Function(String?)? validator;
  final EdgeInsets? padding;

  const CustomDropdown({
    super.key,
    required this.prefixIcon,
    required this.hints,
    required this.value,
    required this.items,
    required this.onChange,
    this.validator,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 18.w),
        child: DropdownButtonFormField(
          dropdownColor: MyColors.lightCard(context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChange,
          validator: validator,
          isExpanded: true,
          itemHeight: 58.h,
          isDense: false,
          hint: Text(hints ?? "Select form here",
            style: MyColors.l7B7B7B_dtext(context).regular18,
          ),
          value: (value ?? '').isEmpty ? null : value,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: MyColors.l111111_dwhite(context).regular16_5,
              ),
            );
          }).toList(),
          decoration: MyDecoration.dropdownDecoration(
            context: context,
            prefixIcon: prefixIcon,
            hints: hints,
          ),
        ),
      ),
    );
  }
}
