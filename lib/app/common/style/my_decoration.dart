import '../../helpers/responsive_helper.dart';
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
        prefixIcon: Icon(prefixIcon, size: 23,
            color: MyColors.l7B7B7B_dicon(context)),
        labelText: hints,
        labelStyle: TextStyle(
          fontFamily: MyAssets.fontKlavika,
          fontWeight: FontWeight.w400,
          color: MyColors.c_7B7B7B,
            fontSize: Get.width>600? 14.sp:null
        ),
        floatingLabelStyle:  TextStyle(
          fontFamily: MyAssets.fontKlavika,
          fontWeight: FontWeight.w600,
          color: MyColors.c_C6A34F,
           fontSize: Get.width>600? 14.sp:null
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
    String? errorText,
    String? selectedIcon,
  }) =>
      InputDecoration(
        errorStyle: const TextStyle(fontSize: 0.01),
        filled: true,
        errorText: errorText,
        fillColor: MyColors.lightCard(context),
        labelText: label,
        labelStyle:  TextStyle(
          fontFamily: MyAssets.fontKlavika,
          fontWeight: FontWeight.w400,
          color: MyColors.lightGrey,
           fontSize:  17,
        ),
        floatingLabelStyle:  TextStyle(
          fontFamily: MyAssets.fontKlavika,
          fontWeight: FontWeight.w600,
          color: MyColors.c_C6A34F,
           fontSize: ResponsiveHelper.isTab(Get.context)?12.sp:17,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: .5, color: MyColors.c_777777),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: MyColors.c_C6A34F),
          borderRadius: BorderRadius.circular(10),
          gapPadding: 10,
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1, color: Colors.redAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static BoxDecoration cardBoxDecoration({
    required BuildContext context,
  }) => BoxDecoration(
    gradient: LinearGradient(
        end: Alignment.topLeft,
        begin: Alignment.bottomRight,
        colors: [
          MyColors.primaryDark.withOpacity(0.2),
          MyColors.primaryLight.withOpacity(0.25),
        ]
    ),
        //color: MyColors.lightCard(context),
        borderRadius: BorderRadius.circular(10.0),
      /*  border: Border.all(
          width: .5,
          color: MyColors.c_A6A6A6,
        ),*/
      );

      static BoxDecoration cardBoxDecorationTransparent({
  required BuildContext context,
}) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return BoxDecoration(
    color: Colors.transparent, // No background color
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: isDarkMode
            ? Colors.black.withOpacity(0.4) // Darker shadow for dark mode
            : Colors.grey.withOpacity(0.3), // Lighter shadow for light mode
        offset: Offset(4, 4),
        blurRadius: 12.0,
        spreadRadius: 1.0,
      ),
      BoxShadow(
        color: isDarkMode
            ? Colors.grey.withOpacity(0.2) // Lighter inner shadow for dark mode
            : Colors.white.withOpacity(0.5), // Light inner shadow for light mode
        offset: Offset(-4, -4),
        blurRadius: 12.0,
        spreadRadius: 1.0,
      ),
    ],
    border: Border.all(
      color: isDarkMode
          ? Colors.grey.withOpacity(0.3)
          : Colors.blueGrey.withOpacity(0.3),
      width: 0.8,
    ),
  );
}

}
