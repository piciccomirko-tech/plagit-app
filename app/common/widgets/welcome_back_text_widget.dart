import 'package:flutter/material.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';

class WelcomeBackTextWidget extends StatelessWidget {
  final String subTitle;
  const WelcomeBackTextWidget({super.key, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Welcome Back!', style: MyColors.l5C5C5C_dwhite(context).semiBold20),
        const SizedBox(height: 10),
        Text(subTitle, style: MyColors.l5C5C5C_dwhite(context).medium16),
      ],
    );
  }
}
