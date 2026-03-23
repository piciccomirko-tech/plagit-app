import 'package:mh/app/common/widgets/custom_appbar.dart';

import '../../../../common/utils/exports.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.contactUs.tr,
        context: context,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30.h),
          Image.asset(
            MyAssets.logo,
            width: Get.width * .4,
            height: Get.width * .4,
          ),
          SizedBox(height: 50.h),
          Text(MyStrings.contactUs.tr,
              style: MyColors.l111111_dwhite(context).semiBold22),
          SizedBox(height: 20.h),
          Divider(color: MyColors.primaryLight,endIndent: 20,indent: 20,),
            SizedBox(height: 20.h),
          GestureDetector(
              onTap: () => controller.launchEmail("info@plagit.com"),
            child: _item(MyStrings.email.tr, "info@plagit.com")),
        ],
      ),
    );
  }

  Widget _item(String title, String value) => Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                     Icon(Icons.email, color: MyColors.primaryDark,),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: MyColors.c_A6A6A6.regular15,
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: MyColors.c_A6A6A6.semiBold16,
            ),
          ),
        ],
      );
}
