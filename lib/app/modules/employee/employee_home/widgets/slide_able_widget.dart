import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import 'package:get/get.dart';

class SlideAbleWidget extends StatefulWidget {
  final bool checkIn;
  final VoidCallback? onSubmit;
  const SlideAbleWidget({super.key, required this.checkIn, required this.onSubmit});

  @override
  State<SlideAbleWidget> createState() => _SlideAbleWidgetState();
}

class _SlideAbleWidgetState extends State<SlideAbleWidget> {
  double _position = 0.0;
  double _needToReduce = Platform.isIOS?10.0:0.0;
  double _containerWidth = 0.0;
  final double _sliderWidth = 70; // Width of sliding button

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth; // Get parent width dynamically

        if (widget.checkIn == true) {
          _position = _containerWidth - _sliderWidth - _needToReduce; // Prevent overflow
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                gradient: Utils.primaryGradient,
              ),
              width: double.infinity,
              height: 52.h,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_position != 0 && widget.checkIn)
                    const SpinKitThreeBounce(
                      color: Colors.white,
                      size: 20,
                    ),
                  if (_position != 0 && widget.checkIn) const SizedBox(width: 10),
                  Text(
                    _position == 0 && !widget.checkIn
                        ? '        ${MyStrings.swipeRight.tr} ${MyStrings.checkIn.tr}'
                        : '${MyStrings.swipeLeft.tr} ${MyStrings.checkOut.tr}        ',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  if (_position == 0 && !widget.checkIn) const SizedBox(width: 10),
                  if (_position == 0 && !widget.checkIn)
                    SpinKitThreeBounce(
                      color: MyColors.white,
                      size: 20,
                    ),
                ],
              ),
            ),

            // Sliding Button
            Positioned(
              left: _position,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _position += details.primaryDelta!;
                    // Prevent slider from going outside the container
                    _position = _position.clamp(0.0, _containerWidth - _sliderWidth - _needToReduce);
                  });
                },
                onHorizontalDragEnd: (DragEndDetails details) {
                  widget.onSubmit?.call();
                  setState(() {
                    // Snap to Check-In or Check-Out position
                    if (_position > (_containerWidth - _sliderWidth) / 2) {
                      _position = _containerWidth - _sliderWidth - _needToReduce;
                    } else {
                      _position = 0.0;
                    }
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.006,
                      left: _position == 0 && !widget.checkIn ? 5 : 0,
                      right: 15.0),
                  child: Container(
                    height: 40.h,
                    width: _sliderWidth.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50.0),
                      color: Colors.white,
                    ),
                    child: Icon(
                      _position == 0 && !widget.checkIn ? Icons.arrow_forward : Icons.arrow_back,
                      color: MyColors.c_C6A34F,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
