import 'package:mh/app/common/utils/exports.dart';

import '../../helpers/responsive_helper.dart';

class WelcomeBackTextWidget extends StatelessWidget {
  final String subTitle;
  const WelcomeBackTextWidget({super.key, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text( MyStrings.welcomeBack.tr, style: ResponsiveHelper.isTab(Get.context)?MyColors.l5C5C5C_dwhite(context).semiBold16:MyColors.l5C5C5C_dwhite(context).semiBold20),
        const SizedBox(height: 10),
        Text(subTitle, style: (ResponsiveHelper.isTab(Get.context)?MyColors.l5C5C5C_dwhite(context).medium9:MyColors.l5C5C5C_dwhite(context).medium16)),
      ],
    );
  }
}
