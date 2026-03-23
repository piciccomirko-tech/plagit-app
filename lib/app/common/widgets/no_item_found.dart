import 'package:lottie/lottie.dart';

import '../../helpers/responsive_helper.dart';
import '../utils/exports.dart';

class NoItemFound extends StatelessWidget {
  const NoItemFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(MyAssets.lottie.notFound, height: 300),
          Text(
            MyStrings.foundNothing.tr,
            style: ResponsiveHelper.isTab(Get.context)?MyColors.l111111_dwhite(context).semiBold10:MyColors.l111111_dwhite(context).semiBold18,
          ),
        ],
      ),
    );
  }
}
