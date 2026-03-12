import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Color color;

  CurvePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, size.height * .6);
    path.quadraticBezierTo(size.width * .4,  size.height * .42, size.width , size.height * .48);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);


    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}