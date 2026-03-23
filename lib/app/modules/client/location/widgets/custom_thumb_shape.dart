import 'package:flutter/material.dart';
import 'package:mh/app/common/utils/exports.dart';

import '../../../../common/values/my_assets.dart';

class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;
  final bool showValue;

  const CustomThumbShape({
    this.thumbRadius = 4.0,
    this.borderWidth = 2.0,
    this.showValue = true,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius + (showValue ? 20 : 0));
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw outer circle (border)
    final Paint borderPaint = Paint()
      ..color =MyColors.primaryDark
      ..style = PaintingStyle.fill
      ..strokeWidth = borderWidth;

    canvas.drawCircle(center, thumbRadius, borderPaint);

    // Draw inner circle (white)
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius - borderWidth, innerPaint);

    if (showValue) {
      // Calculate the actual value (0.5 to 10.0)
      final actualValue = value * 49.5 + 0.5;
      final valueStr = actualValue.toStringAsFixed(1);

      // Create text painter
      final textSpan = TextSpan(
        text: '$valueStr km',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 10,
          fontFamily: MyAssets.fontMontserrat,
          fontWeight: FontWeight.w500,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      // Draw white container background with triangle
      final containerPath = Path();
      final containerWidth = textPainter.width + 16;
      final containerHeight = 24.0;
      final triangleHeight = 6.0;
      final triangleWidth = 8.0;
      final verticalOffset = thumbRadius * 2 + 14; // Increased offset to position below circle
      
      // Starting point (top center of triangle)
      containerPath.moveTo(center.dx, center.dy + verticalOffset - containerHeight/2 - triangleHeight);
      
      // Draw triangle
      containerPath.lineTo(center.dx - triangleWidth/2, center.dy + verticalOffset - containerHeight/2);
      containerPath.lineTo(center.dx + triangleWidth/2, center.dy + verticalOffset - containerHeight/2);
      containerPath.close();
      
      // Draw rounded rectangle container
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + verticalOffset),
          width: containerWidth,
          height: containerHeight,
        ),
        const Radius.circular(8),
      );
      containerPath.addRRect(rect);

      // Draw container shadow
      final shadowPath = Path()..addPath(containerPath, const Offset(0, 1));
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawPath(shadowPath, shadowPaint);

      // Draw white container with triangle
      final containerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawPath(containerPath, containerPaint);

      // Draw stroke around container and triangle
      final strokePaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(containerPath, strokePaint);

      // Position text in container
      final textCenter = Offset(
        center.dx - textPainter.width / 2,
        center.dy + verticalOffset - containerHeight/4,
      );
      textPainter.paint(canvas, textCenter);
    }
  }
}
