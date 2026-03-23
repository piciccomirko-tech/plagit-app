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
  final bool isValid;

  const CustomDropdown({
    super.key,
    required this.prefixIcon,
    required this.hints,
    required this.value,
    required this.items,
    required this.onChange,
    this.validator,
    this.padding,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.width > 600 ? 52.h : 60.w,
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: 18.sp),
        child: DropdownButtonFormField(
          dropdownColor: MyColors.lightCard(context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (newValue) {
            onChange(newValue); // Ensure onChange handles dynamic validation
          },
          
          validator: validator,
          isExpanded: true,
          isDense: false,
          hint: Text(
            hints ?? MyStrings.selectFromHere.tr,
            style: Get.width > 600
                ? (MyColors.l7B7B7B_dtext(context).regular9)
                    .copyWith(fontSize: 15.sp)
                : MyColors.l7B7B7B_dtext(context).regular18,
          ),
          value: (value ?? '').isEmpty ? null : value,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: Get.width > 600
                    ? (MyColors.l111111_dwhite(context).regular9)
                        .copyWith(fontSize: 15.sp)
                    : MyColors.l111111_dwhite(context).regular16_5,
              ),
            );
          }).toList(),
          decoration: MyDecoration.dropdownDecoration(
            context: context,
            prefixIcon: prefixIcon,
            hints: hints,
          ).copyWith(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: isValid ? MyColors.noColor : Colors.red,
                width: 0.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: isValid ? MyColors.noColor : Colors.red,
                width: 0.3,
              ),
            ),
            errorText: isValid ? null : "Please select a $hints",
          ).copyWith( 
             contentPadding: EdgeInsets.symmetric( horizontal: 12.0),
             ),
        ),
      ),
    );
  }
}
