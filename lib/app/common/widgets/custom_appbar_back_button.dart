import '../utils/exports.dart';

class CustomAppbarBackButton extends StatelessWidget {
  const CustomAppbarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        height: 24.h,
        width: 24.h,
        decoration: BoxDecoration(
          color: MyColors.c_DDBD68,
          borderRadius: BorderRadius.circular(3.86),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );
  }
}
