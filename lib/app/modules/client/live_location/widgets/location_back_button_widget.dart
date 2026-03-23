import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';

class LocationBackButtonWidget extends StatelessWidget {
  const LocationBackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, left: 10.0),
      child: InkResponse(
        onTap: () => Get.back(),
        child: Container(
          height: 35,
          width: 35,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(5.0)),
          child: const Icon(CupertinoIcons.chevron_back, color: Colors.white, size: 25),
        ),
      ),
    );
  }
}
