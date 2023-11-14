import '../utils/exports.dart';

class CustomHelpSupport extends StatelessWidget {
  final Function() onTap;

  const CustomHelpSupport({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(width: 0.5, color: MyColors.c_A6A6A6),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                MyAssets.helpSupport,
                width: 38.w,
                height: 38.w,
              ),

              SizedBox(width: 20.w),

              Text(
                MyStrings.helpSupport.tr,
                style: MyColors.l111111_dwhite(context).medium16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
