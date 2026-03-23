import 'package:flutter/material.dart';
import 'package:linkable/linkable.dart';
import 'package:mh/app/common/utils/exports.dart';

class CopyableTextWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color textColor;
  final Color linkColor;

  const CopyableTextWidget({
    super.key,
    required this.text,
    required this.textStyle,
    this.textColor = Colors.white,
    this.linkColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Linkable(
      textAlign: TextAlign.start,
      text: text.trim(),
      textScaleFactor: 1,
      textWidthBasis: TextWidthBasis.longestLine,
      style: textStyle,
      textColor: textColor,
      linkColor: linkColor,
    );
  }
}
