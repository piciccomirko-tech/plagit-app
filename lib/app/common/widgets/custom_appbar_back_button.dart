import '../utils/exports.dart';

class CustomAppbarBackButton extends StatelessWidget {
  const CustomAppbarBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: MyColors.c_C6A34F,
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
