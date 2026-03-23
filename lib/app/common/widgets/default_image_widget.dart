import 'package:flutter/material.dart';
import 'package:mh/app/common/utils/exports.dart';

class DefaultImageWidget extends StatelessWidget {
  final String defaultImagePath;
  final double? radius;
  const DefaultImageWidget(
      {super.key, required this.defaultImagePath, this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 100),
      child: Image.asset(
        defaultImagePath,
        height: radius ?? 100,
        width: radius ?? 100,
        fit: BoxFit.cover,
      ),
    );
  }
}
