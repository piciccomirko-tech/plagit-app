import '../utils/exports.dart';


/// text color summary
/*
      title           light            dark          weight
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      headline1       c_111111         white         w600
      headline2       white            c_111111      w600
      headline3       c_858585         text          w500
      bodyText1       c_50555C         text
      bodyText2       c_111111         text

 */

class AppTheme {
  AppTheme._();

  static ThemeData get light => _common.copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: MyColors.c_F6F6F6,
        cardColor: MyColors.c_FFFFFF,
        dividerColor: MyColors.c_111111,
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(
            color: MyColors.c_111111,
          ),
          titleTextStyle: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 18.sp,
            color: MyColors.c_111111,
          ),
        ),
        // textTheme: const TextTheme(
        //   headline1: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w600,
        //     color: MyColors.c_111111,
        //   ),
        //   headline2: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w600,
        //     color: MyColors.white,
        //   ),
        //   headline3: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w500,
        //     color: MyColors.c_858585,
        //   ),
        //   bodyText1: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     color: MyColors.c_111111,
        //   ),
        //   bodyText2: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     color: MyColors.c_50555C,
        //   ),
        // ),
      );

  static ThemeData get dark => _common.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: MyColors.frameBg,
        cardColor: MyColors.box,
        dividerColor: MyColors.stock,
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(
            color: MyColors.white,
          ),
          titleTextStyle: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 18.sp,
            color: MyColors.white,
          ),
        ),
        // textTheme: const TextTheme(
        //   headline1: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w600,
        //     color: MyColors.white,
        //   ),
        //   headline2: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w600,
        //     color: MyColors.c_111111,
        //   ),
        //   headline3: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontWeight: FontWeight.w500,
        //     color: MyColors.text,
        //   ),
        //   bodyText1: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     color: MyColors.text,
        //   ),
        //   bodyText2: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     color: MyColors.text,
        //   ),
        // ),
      );

  static ThemeData get _common => ThemeData(
        fontFamily: MyAssets.fontMontserrat,
      );
}
