import '../utils/exports.dart';

class CustomAppbarBackButton extends StatelessWidget {
  const CustomAppbarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        height: Get.width>600?35: 25.w,
        width: Get.width>600?35: 25.w,
        decoration: BoxDecoration(
          color: MyColors.c_C6A34F,
          borderRadius: BorderRadius.circular(3.86),
        ),
        child:  Center(
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16.w,
          ),
        ),
      ),
    );
  }
}
