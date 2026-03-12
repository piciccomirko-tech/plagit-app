import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mh/app/common/values/my_color.dart';

class RefreshWidget extends StatelessWidget {
  final void Function() onTap;
  const RefreshWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: const CircleAvatar(
          backgroundColor: MyColors.c_C6A34F, child: Icon(CupertinoIcons.refresh, color: Colors.white, size: 20)),
    );
  }
}
