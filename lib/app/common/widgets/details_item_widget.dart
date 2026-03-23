import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';

class DetailsItemWidget extends StatelessWidget {
  final String icon;
  final String title;
  final Widget value;
  const DetailsItemWidget({super.key, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: 18.w,
          height: 18.w,
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: MyColors.l7B7B7B_dtext(context).medium13,
        ),
        Visibility(visible: title.isNotEmpty, child: SizedBox(width: 3.w)),
        value
      ],
    );
  }
}
