// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:mh/app/common/utils/exports.dart';

class MyColors {
  MyColors._();

  static bool _isLight(context) => Theme.of(context).brightness == Brightness.light;

  static Color l111111_dbox(BuildContext context) => _isLight(context) ? c_111111 : box;
  static Color l111111_dwhite(BuildContext context) => l111111_dffffff(context);
  static Color lwhite_d111111(BuildContext context) => _isLight(context) ? c_FFFFFF : c_111111;
  static Color l111111_dffffff(BuildContext context) => _isLight(context) ? c_111111 : c_FFFFFF;
  static Color l111111_dtext(BuildContext context) => _isLight(context) ? c_111111 : text;
  static Color lffffff_dbox(BuildContext context) => _isLight(context) ? c_FFFFFF : box;
  static Color lffffff_dframeBg(BuildContext context) => _isLight(context) ? c_FFFFFF : frameBg;
  static Color lffffff_dstock(BuildContext context) => _isLight(context) ? c_FFFFFF : stock;
  static Color lbox_dffffff(BuildContext context) => _isLight(context) ? box : c_FFFFFF;
  static Color lF6F6F6_dframeBg(BuildContext context) => _isLight(context) ? c_F6F6F6 : frameBg;
  static Color l7B7B7B_dicon(BuildContext context) => _isLight(context) ? c_7B7B7B : icon;
  static Color l7B7B7B_dtext(BuildContext context) => _isLight(context) ? c_7B7B7B : text;
  static Color l313131_dtext(BuildContext context) => _isLight(context) ? c_313131 : text;
  static Color l50555C_dtext(BuildContext context) => _isLight(context) ? c_50555C : text;
  static Color l777777_dtext(BuildContext context) => _isLight(context) ? c_777777 : text;
  static Color l858585_dtext(BuildContext context) => _isLight(context) ? c_858585 : text;
  static Color lA6A6A6_dstock(BuildContext context) => _isLight(context) ? c_A6A6A6 : stock;
  static Color lD9D9D9_dstock(BuildContext context) => _isLight(context) ? c_D9D9D9 : stock;
  static Color lFAFAFA_dframeBg(BuildContext context) => _isLight(context) ? c_FAFAFA : frameBg;
  static Color l5C5C5C_dwhite(BuildContext context) => _isLight(context) ? c_5C5C5C : white;
  static Color? lnull_d111111(BuildContext context) => _isLight(context) ? null : c_111111;

  static Color lightCard(BuildContext context) => lffffff_dbox(context);
  static Color darkCard(BuildContext context) => lbox_dffffff(context);

  ///  color by name
  static const Color primaryDark = c_C6A34F;
  static const Color primaryLight = c_DDBD68;
  static const Color white = c_FFFFFF;
  static const Color black = c_111111;

  static const Color frameBg = Color(0xff13131A);
  static const Color text = icon;
  static const Color stock = icon;
  static const Color icon = Color(0xff92929D);
  static const Color box = Color(0xff292932);

  ///  color with code
  static const Color c_FFFFFF = Color(0xffFFFFFF);
  static const Color c_7B7B7B = Color(0xff7B7B7B);
  static const Color c_111111 = Color(0xff111111);
  static const Color c_C6A34F = Color(0xffC6A34F);
  static const Color c_A6A6A6 = Color(0xffA6A6A6);
  static const Color c_313131 = Color(0xff313131);
  static const Color c_FAFAFA = Color(0xffFAFAFA);
  static const Color c_000000 = Color(0xff000000);
  static const Color c_DDBD68 = Color(0xffDDBD68);
  static const Color c_5C5C5C = Color(0xff5C5C5C);
  static const Color c_D9D9D9 = Color(0xffD9D9D9);
  static const Color c_777777 = Color(0xff777777);
  static const Color c_FFA800 = Color(0xffFFA800);
  static const Color c_DADADA = Color(0xffDADADA);
  static const Color c_858585 = Color(0xff858585);
  static Color c_00C92C = const Color(0xff00C92C);
  static Color c_00C92C_10 = const Color(0xff00C92C).withOpacity(.1);
  static const Color c_F5F5F5 = Color(0xffF5F5F5);
  static const Color c_FF5029 = Color(0xffFF5029);
  static const Color c_C92C1A = Color(0xffC92C1A);
  static const Color c_FFEDEA = Color(0xffFFEDEA);
  static const Color c_FFC477 = Color(0xffFFC477);
  static const Color c_50555C = Color(0xff50555C);
  static const Color c_FFCEBF = Color(0xffFFCEBF);
  static Color c_000000_30 = const Color(0xff000000).withOpacity(.3);
  static Color c_000000_20 = const Color(0xff000000).withOpacity(.2);
  static const Color c_FABDAB = Color(0xffFABDAB);
  static const Color c_C4C4C4 = Color(0xffC4C4C4);
  static Color c_C6A34F_22 = const Color(0xffC6A34F).withOpacity(.22);
  static const Color c_E5FAEA = Color(0xffE5FAEA);
  static const Color c_F9B6A6 = Color(0xffF9B6A6);
  static const Color c_FEC9A3 = Color(0xffFEC9A3);
  static Color c_FF5029_10 = const Color(0xffFF5029).withOpacity(.1);
  static const Color c_F6F6F6 = Color(0xffF6F6F6);
  static const Color c_909090 = Color(0xff909090);
  static final Color shimmerColor = Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
}
