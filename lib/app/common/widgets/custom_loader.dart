import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/exports.dart';

class CustomLoader {
  static Future show(
    BuildContext context,
  ) {
    hide;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return loading();
      },
    );
  }

  static hide(BuildContext context) {
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      Navigator.of(context).pop();
    }
  }

  static Column loading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          MyAssets.logo,
          height: 140.w,
          width: 140.w,
        ),
        SizedBox(height: 20.h),
        const SpinKitCircle(
          color: MyColors.c_C6A34F,
          size: 55,
        ),
      ],
    );
  }
}
