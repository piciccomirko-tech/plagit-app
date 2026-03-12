import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class HeaderImageWidget extends StatelessWidget {
  final String imageUrl;
  const HeaderImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(imageUrl, height: Get.width * 0.5, width: Get.width * 0.5));
  }
}
