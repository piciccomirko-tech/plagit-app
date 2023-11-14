import '../utils/exports.dart';

class MyDecoration {
  static final MyDecoration _instance = MyDecoration._();

  factory MyDecoration() {
    return _instance;
  }

  MyDecoration._();

  static InputDecoration dropdownDecoration({
    required BuildContext context,
    IconData? prefixIcon,
    String? hints,
  }) =>
      InputDecoration(
        errorStyle: const TextStyle(fontSize: 0.01),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
        prefixIcon: Icon(prefixIcon, color: MyColors.l7B7B7B_dicon(context)),
        labelText: hints,
        labelStyle: const TextStyle(
          fontFamily: MyAssets.fontMontserrat,
          fontWeight: FontWeight.w400,
          color: MyColors.c_7B7B7B,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: MyAssets.fontMontserrat,
          fontWeight: FontWeight.w600,
          color: MyColors.c_C6A34F,
        ),
        // contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1),
          borderRadius: BorderRadius.circular(10.73),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: .5, color: MyColors.c_777777),
          borderRadius: BorderRadius.circular(10.73),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: MyColors.c_C6A34F),
          borderRadius: BorderRadius.circular(10.73),
          gapPadding: 10,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10.73),
        ),
        hintMaxLines: 1,
      );

  static InputDecoration inputFieldDecoration({
    required BuildContext context,
    required String label,
    IconData? prefixIcon,
    String? selectedIcon,
  }) =>
      InputDecoration(
        errorStyle: const TextStyle(fontSize: 0.01),
        filled: true,
        fillColor: MyColors.lightCard(context),
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: MyAssets.fontMontserrat,
          fontWeight: FontWeight.w400,
          color: MyColors.c_7B7B7B,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: MyAssets.fontMontserrat,
          fontWeight: FontWeight.w600,
          color: MyColors.c_C6A34F,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1),
          borderRadius: BorderRadius.circular(10.73),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: .5, color: MyColors.c_777777),
          borderRadius: BorderRadius.circular(10.73),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: MyColors.c_C6A34F),
          borderRadius: BorderRadius.circular(10.73),
          gapPadding: 10,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10.73),
        ),
      );

  static BoxDecoration cardBoxDecoration({
    required BuildContext context,
  }) => BoxDecoration(
        color: MyColors.lightCard(context),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          width: .5,
          color: MyColors.c_A6A6A6,
        ),
      );
}
