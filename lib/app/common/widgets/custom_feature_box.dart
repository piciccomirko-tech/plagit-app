import '../style/my_decoration.dart';
import '../utils/exports.dart';

class CustomFeatureBox extends StatelessWidget {
  final String title;
  final String icon;
  final bool visibleMH;
  final Function() onTap;
  final double? iconHeight;
  final bool loading;
  final double? height;

  const CustomFeatureBox(
      {super.key,
      required this.title,
      required this.icon,
      this.visibleMH = false,
      required this.onTap,
      this.iconHeight,
      this.loading = false,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 150.h,
      decoration: MyDecoration.cardBoxDecoration(context: context),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: loading ? null : onTap,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(
                    backgroundColor: MyColors.c_C6A34F,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      icon,
                      width: iconHeight ?? 60.w,
                      height: iconHeight ?? 60.w,
                    ),
                    SizedBox(height: iconHeight == null ? 6.h : 70.w - iconHeight!),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: visibleMH,
                          child: Text(
                            MyStrings.mh.tr,
                            style: MyColors.c_C6A34F.semiBold16,
                          ),
                        ),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: height == 120
                              ? MyColors.l111111_dwhite(context).medium12
                              : MyColors.l111111_dwhite(context).medium15,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
