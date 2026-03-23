import 'package:mh/app/helpers/responsive_helper.dart';

import '../utils/exports.dart';

class CustomAppbarBackButton extends StatelessWidget {
   final VoidCallback? onPressed;

  const CustomAppbarBackButton({Key? key, this.onPressed}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: Get.back,
      onTap: onPressed ?? () => Navigator.of(context).pop(), // Use callback if provided, otherwise default to Navigator.pop(),
      child: Container(
        margin:  EdgeInsets.all(ResponsiveHelper.isTab(Get.context)?10:0),
        height: 25.sp,
        width: 25.sp,
        decoration: BoxDecoration(
          color: MyColors.c_C6A34F,
          borderRadius: BorderRadius.circular(3.86),
        ),
        child:  Center(
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: ResponsiveHelper.isTab(Get.context)?10.sp:16.sp,
          ),
        ),
      ),
    );
  }
}
