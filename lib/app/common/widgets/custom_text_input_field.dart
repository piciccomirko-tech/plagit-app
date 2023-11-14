
import '../style/my_decoration.dart';
import '../utils/exports.dart';

class CustomTextInputField extends StatefulWidget {
  final IconData? prefixIcon;
  final String? selectedIcon;
  final String? unselectedIcon;
  final EdgeInsets? padding;
  final bool isPasswordField;
  final bool isMapField;
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? Function(String?)? onChange;
  final TextInputType? textInputType;
  final bool readOnly;
  final GestureTapCallback? onTap;
  final Function()? onSubmit;
  final Function()? onSuffixPressed;

  const CustomTextInputField({
    super.key,
    this.prefixIcon,
    this.selectedIcon,
    this.unselectedIcon,
    this.padding,
    this.isPasswordField = false,
    this.isMapField = false,
    required this.label,
    this.controller,
    this.validator,
    this.onChange,
    this.textInputType,
    this.readOnly = false,
    this.onTap,
    this.onSubmit,
    this.onSuffixPressed,
  });

  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {

  bool _focus = false;
  bool _showPassword = false;

  void _onFocusChange(focus) {
    _focus = focus;
    setState(() {});
  }

  void _passwordVisibleToggle() {
    _showPassword = !_showPassword;
    setState(() {});
  }

  void _onSubmit() {
    if(widget.onSubmit != null) {
      widget.onSubmit!();
    }

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 18.w),
        child: FocusScope(
          child: Focus(
            onFocusChange: _onFocusChange,
            child: TextFormField(
              controller: widget.controller,
              readOnly: widget.readOnly,
              keyboardType: widget.textInputType,
              cursorColor: MyColors.c_C6A34F,
              obscureText: widget.isPasswordField & !_showPassword,
              validator: widget.validator,
              onChanged: widget.onChange,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: MyColors.l111111_dwhite(context).regular16_5,
              onTap: widget.onTap,
              onFieldSubmitted: (value) => _onSubmit(),
              decoration: MyDecoration.inputFieldDecoration(
                context: context,
                label: widget.label,
              ).copyWith(
                contentPadding: const EdgeInsets.all(12),
                isDense: true,
                prefixIcon: widget.prefixIcon == null
                    ? Image.asset(
                        _focus ? widget.selectedIcon! : widget.selectedIcon!,
                      )
                    : Icon(
                        widget.prefixIcon,
                        color: _focus ? MyColors.c_C6A34F : MyColors.c_7B7B7B,
                      ),
                suffixIcon: widget.isPasswordField
                    ? GestureDetector(
                        onTap: _passwordVisibleToggle,
                        child: Icon(
                          _showPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _focus ? MyColors.c_C6A34F : MyColors.c_7B7B7B,
                        ),
                      )
                    : widget.isMapField
                        ? GestureDetector(
                            onTap: widget.onSuffixPressed,
                            child: Icon(
                              Icons.location_on_rounded,
                              color: _focus ? MyColors.c_C6A34F : MyColors.c_7B7B7B,
                            ),
                          )
                        : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
