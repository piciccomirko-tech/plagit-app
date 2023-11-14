import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';

class SlideAbleWidget extends StatefulWidget {
  final bool checkIn;
  final VoidCallback? onSubmit;
  const SlideAbleWidget({super.key, required this.checkIn, required this.onSubmit});

  @override
  State<SlideAbleWidget> createState() => _SlideAbleWidgetState();
}

class _SlideAbleWidgetState extends State<SlideAbleWidget> {
  double _position = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.checkIn == true) {
      _position = MediaQuery.of(context).size.width - 105;
    }
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: MyColors.c_C6A34F,
            ),
            width: double.infinity,
            height: 60,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_position != 0 && widget.checkIn == true)
                  const SpinKitThreeBounce(
                    color: MyColors.white,
                    size: 20,
                  ),
                if (_position != 0 && widget.checkIn == true)  const SizedBox(width: 10),
                Text(
                    _position == 0 && widget.checkIn == false
                        ? '        Swipe right to checkin'.toUpperCase()
                        : 'Swipe left to checkout        '.toUpperCase(),
                    style: MyColors.white.semiBold14),
                if (_position == 0 && widget.checkIn == false)  const SizedBox(width: 10),
                if (_position == 0 && widget.checkIn == false)
                  const SpinKitThreeBounce(
                    color: MyColors.white,
                    size: 20,
                  )
              ],
            ),
          ),
          Positioned(
            left: _position,
            child: GestureDetector(
              onHorizontalDragUpdate: (DragUpdateDetails details) {
                setState(() {
                  _position += details.primaryDelta!;
                  if (_position < 0) {
                    _position = 0;
                  } else if (_position > MediaQuery.of(context).size.width - 50) {
                    _position = MediaQuery.of(context).size.width - 65;
                  }
                });
              },
              onHorizontalDragEnd: (DragEndDetails details) {
                widget.onSubmit!();
                setState(() {
                  if (_position > MediaQuery.of(context).size.width - 100) {
                    _position = MediaQuery.of(context).size.width - 105;
                  } else {
                    _position = 0.0;
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.005, left: 5.0),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _position == 0 && widget.checkIn == false ? Icons.arrow_forward : Icons.arrow_back,
                    color: MyColors.c_C6A34F,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
