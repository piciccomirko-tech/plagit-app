import 'package:flutter/services.dart';

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
  final Function(String)? onChange; // Updated type here
  final TextInputType? textInputType;
  final bool readOnly;
  final GestureTapCallback? onTap;
  final Function()? onSubmit;
  final Function()? onSuffixPressed;
  final bool isRequired;
  final bool isValid;

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
    this.onChange, // Make sure this handles onChange dynamically
    this.textInputType,
    this.readOnly = false,
    this.onTap,
    this.onSubmit,
    this.onSuffixPressed,
    this.isRequired = false,
    this.isValid = true,
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
    if (widget.onSubmit != null) {
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
              onChanged: (value) {
                if (widget.onChange != null) {
                  widget.onChange!(value); // Properly handle onChange here
                }
              },
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: Get.width > 600
                  ? (MyColors.l111111_dwhite(context).regular9)
                      .copyWith(fontSize: 12.sp)
                  : MyColors.l111111_dwhite(context).regular17,
              onTap: widget.onTap,
              onFieldSubmitted: (value) => _onSubmit(),
              decoration: MyDecoration.inputFieldDecoration(
                context: context,
                label: widget.label,
              )
                  .copyWith(
                    contentPadding: const EdgeInsets.all(12),
                    isDense: true,
                    prefixIcon: widget.prefixIcon == null
                        ? Image.asset(
                            height: 23.h,
                            width: 23.w,
                            _focus
                                ? widget.selectedIcon!
                                : widget.selectedIcon!,
                          )
                        : Icon(
                            size: 23,
                            widget.prefixIcon,
                            color:
                                _focus ? MyColors.c_C6A34F : MyColors.c_7B7B7B,
                          ),
                    suffixIcon: widget.isPasswordField
                        ? GestureDetector(
                            onTap: _passwordVisibleToggle,
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: _focus
                                  ? MyColors.c_C6A34F
                                  : MyColors.c_7B7B7B,
                            ),
                          )
                        : widget.isMapField
                            ? GestureDetector(
                                onTap: widget.onSuffixPressed,
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: _focus
                                      ? MyColors.c_C6A34F
                                      : MyColors.c_7B7B7B,
                                ),
                              )
                            : null,
                    // suffix: Text(
                    //   widget.isValid ? '*' : '',
                    //   style: TextStyle(
                    //       color: Colors.red,
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 15),
                    // ), // Add red asterisk after label
                  )
                  .copyWith(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: widget.isValid ? MyColors.noColor : Colors.red,
                        width: 0.3,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: widget.isValid ? MyColors.noColor : Colors.red,
                        width: 0.3,
                      ),
                    ),
                    errorText:
                        widget.isValid ? null : "Enter a valid ${widget.label}",
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
