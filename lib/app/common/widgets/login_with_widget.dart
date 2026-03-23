import 'dart:io';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_image_widget.dart';
import 'package:mh/app/enums/social_login.dart';

class LoginWithWidget extends StatelessWidget {
  final String title;
  final void Function({required SocialLogin type}) socialLogin;
  const LoginWithWidget(
      {super.key, required this.title, required this.socialLogin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 2,
                width: 100.w,
                color: MyColors.lightGrey,
              ),
              SizedBox(width: 20.w),
              Text(title, style: MyColors.l111111_dwhite(context).regular18),
              SizedBox(width: 20.w),
              Container(
                height: 2,
                width: 100.w,
                color: MyColors.lightGrey,
              )
            ],
          ),
          SizedBox(height: 15.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialLoginWidget(type: SocialLogin.google),
              if(Platform.isIOS)
              SizedBox(width: 15.w),
              if(Platform.isIOS)
              _socialLoginWidget(type: SocialLogin.apple)
            ],
          ),
          SizedBox(height: 15.w),
          Text("or", style: MyColors.l111111_dwhite(context).regular18),
          SizedBox(height: 15.w)
        ],
      ),
    );
  }

  Widget _socialLoginWidget({required SocialLogin type}) {
    return GestureDetector(
      onTap: () => socialLogin(type: type),
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12, // Light shadow color
              blurRadius: 8.0, // Spread of the shadow (for softer shadow)
              offset: Offset(2, 2), // Position of the shadow
            ),
          ],
        ),
        child: CustomImageWidget(
          imgAssetPath:
          type == SocialLogin.apple ? MyAssets.apple : MyAssets.google,
          height: 30.w,
          width: 30.w,
        ),
      )
    );
  }
}
