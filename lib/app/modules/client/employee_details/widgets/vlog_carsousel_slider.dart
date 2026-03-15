import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/client/employee_details/widgets/custom_image_widget.dart';
import 'package:mh/app/modules/client/employee_details/widgets/custom_video_widget.dart';

class VlogCarouselSlider extends StatefulWidget {
  final List<VlogModel> vlogs;
  final double height;

  const VlogCarouselSlider({super.key, required this.vlogs, required this.height});

  @override
  VlogCarouselSliderState createState() => VlogCarouselSliderState();
}

class VlogCarouselSliderState extends State<VlogCarouselSlider> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.vlogs.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_pageController.hasClients) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.vlogs.length) nextPage = 0;
        _pageController.animateToPage(nextPage,
            duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.vlogs.isNotEmpty,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: widget.height,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.vlogs.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final VlogModel vlog = widget.vlogs[index];

                    Widget mediaWidget;

                    if (vlog.type == "image") {
                      mediaWidget = CustomImageWidget(
                        fit: BoxFit.cover,
                        radius: 10,
                        height: widget.height,
                        width: double.infinity,
                        imgUrl: (vlog.link ?? "").uniformImageUrl,
                      );
                    } else if (vlog.type == "video") {
                      mediaWidget = CustomVideoWidget(
                          videoUrl: (vlog.link ?? "").uniformImageUrl, height: widget.height);
                    } else {
                      mediaWidget = Container();
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.0.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Stack(
                        children: [
                          mediaWidget,
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 10.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Text(vlog.title ?? '', style: MyColors.white.semiBold14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 5,
                top: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: MyColors.c_C6A34F,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: MyColors.white,
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.chevron_back, color: MyColors.c_C6A34F),
                      onPressed: () {
                        if (_pageController.hasClients && _currentIndex > 0) {
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: MyColors.c_C6A34F,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: MyColors.white,
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.chevron_forward, color: MyColors.c_C6A34F),
                      onPressed: () {
                        if (_pageController.hasClients &&
                            _currentIndex < widget.vlogs.length - 1) {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          CircleIndicator(
            currentIndex: _currentIndex,
            itemCount: widget.vlogs.length,
            color: MyColors.c_C6A34F.withOpacity(0.3),
            selectedColor: MyColors.c_C6A34F,
          ),
          SizedBox(height: 12.h)
        ],
      ),
    );
  }
}

class CircleIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final Color color;
  final Color selectedColor;

  const CircleIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    required this.color,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Container(
          width: index == currentIndex ? 30.0 : 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: index == currentIndex ? selectedColor : color,
          ),
        );
      }),
    );
  }
}
