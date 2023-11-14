import '../../../common/utils/exports.dart';
import '../../../common/widgets/custom_appbar.dart';
import '../controllers/contact_us_controller.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Contact Us",
        context: context,
      ),
      body: Column(
        children: [
          SizedBox(height: 30.h),

          Image.asset(
            MyAssets.logo,
            width: Get.width * .4,
            height: Get.width * .4,
          ),

          SizedBox(height: 50.h),

          Text("Contact Us", style: MyColors.l111111_dwhite(context).semiBold22),

          SizedBox(height: 30.h),

          _item("Phone", "07500-146699"),
          SizedBox(height: 20.h),
          _item("Email", "info@mirkohospitality.com"),
          SizedBox(height: 20.h),
          _item("Location", "48 Warwick St Regent Street\nW1B 5AW London"),

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
                Text(title, style: MyColors.c_A6A6A6.regular15,),
                SizedBox(width: 12.w),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(value, style: MyColors.c_A6A6A6.semiBold16,),
          ),
        ],
      );
}
