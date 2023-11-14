import '../utils/exports.dart';

class CustomButtons {
  static final CustomButtons _instance = CustomButtons._();

  factory CustomButtons() => _instance;

  CustomButtons._();

  static Widget button({
    String text = "Continue",
    Color? backgroundColor,
    Function()? onTap,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? height,
    double? fontSize,
    CustomButtonStyle customButtonStyle = CustomButtonStyle.regular,
    BuildContext? context,
  }) =>
      Container(
        height: height?.h ?? 48.h,
        margin: margin ?? EdgeInsets.symmetric(horizontal: 37.0.w),
        padding: padding,
        decoration: _getButtonStyle(customButtonStyle, context, onTap != null, color: backgroundColor),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: _getRadius(customButtonStyle),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(customButtonStyle),
                ),
              ),
            ),
          ),
        ),
      );

  /// styles
  static BoxDecoration _regular(BorderRadius radius) => BoxDecoration(
        color: MyColors.c_C6A34F,
        borderRadius: radius,
      );

  static BoxDecoration _outline(BorderRadius radius, context) => BoxDecoration(
        color: MyColors.lightCard(context),
        borderRadius: radius,
        border: Border.all(
          width: 2,
          color: MyColors.c_C6A34F,
        ),
      );

  static BoxDecoration _radiusTopBottomCorner(BorderRadius radius, bool isActive, {Color? color}) => BoxDecoration(
        color: isActive ? color ?? MyColors.c_C6A34F : MyColors.c_A6A6A6,
        borderRadius: radius,
      );

  /// helper
  static BoxDecoration _getButtonStyle(CustomButtonStyle customButtonStyle, context, bool isActive, {Color? color}) {
    switch (customButtonStyle) {
      case CustomButtonStyle.outline:
        return _outline(_getRadius(customButtonStyle), context);
      case CustomButtonStyle.radiusTopBottomCorner:
        return _radiusTopBottomCorner(_getRadius(customButtonStyle), isActive, color: color);
      case CustomButtonStyle.regular:
      default:
        return _regular(_getRadius(customButtonStyle));
    }
  }

  static Color _getTextColor(CustomButtonStyle customButtonStyle) {
    switch (customButtonStyle) {
      case CustomButtonStyle.outline:
        return MyColors.c_C6A34F;
      case CustomButtonStyle.radiusTopBottomCorner:
      case CustomButtonStyle.regular:
      default:
        return MyColors.white;
    }
  }

  static BorderRadius _getRadius(CustomButtonStyle customButtonStyle) {
    switch (customButtonStyle) {
      case CustomButtonStyle.radiusTopBottomCorner:
        return const BorderRadius.only(
          topLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        );
      case CustomButtonStyle.regular:
      case CustomButtonStyle.outline:
      default:
        return BorderRadius.circular(10.0);
    }
  }
}
