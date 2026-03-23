import 'package:flutter/material.dart';
import 'package:mh/app/common/utils/exports.dart';

class SocialAuthWidget extends StatelessWidget {
  final String type;
  final String title;

  const SocialAuthWidget({
    Key? key,
    required this.type,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Divider(
                thickness: 1, // Adjust thickness as needed
                color: MyColors.c_A6A6A6,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Divider(
                thickness: 1, // Adjust thickness as needed
                color: MyColors.c_A6A6A6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIconButton('assets/images/google.png', () {
              // Handle Google login logic using GetX or Firebase
            }),
            const SizedBox(width: 15),
            _socialIconButton('assets/images/apple.png', () {
              // Handle Apple login logic using GetX or Firebase
            }),
            const SizedBox(width: 15),
            _socialIconButton('assets/images/facebook.png', () {
              // Handle Facebook login logic using GetX or Firebase
            }),
          ],
        ),
         SizedBox(height: 10.h),
        const Text(
          'OR',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
          SizedBox(height: 10.h),
      ],
    );
  }

  Widget _socialIconButton(String iconPath, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: MyColors.c_A6A6A6, 
          borderRadius: BorderRadius.circular(50)
        ),
        child: CircleAvatar(
          radius: 44.r,
          backgroundColor: Colors.white,
          child: Image.asset(
            iconPath,
            width: 44.w,
            height: 44.w,
          ),
        ),
      ),
    );
  }
}
