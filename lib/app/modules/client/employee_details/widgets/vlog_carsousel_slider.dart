import 'package:carousel_slider/carousel_slider.dart' hide CarouselController;
import 'package:carousel_slider/carousel_controller.dart' as cs;
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

late cs.CarouselController _carouselController;
  
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = cs.CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.vlogs.isNotEmpty,
      child: Column(
        children: [
          Stack(
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: widget.vlogs.length,
                itemBuilder: (context, index, realIndex) {
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
                    mediaWidget = CustomVideoWidget(videoUrl: (vlog.link ?? "").uniformImageUrl, height: widget.height);
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
                options: CarouselOptions(
                  height: widget.height,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 15),
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    setState(() {
                      _currentIndex = index;
                    });
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
                        _carouselController.previousPage();
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
                        _carouselController.nextPage();
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
            // shape: index == currentIndex ? BoxShape.rectangle : BoxShape.circle,
            color: index == currentIndex ? selectedColor : color,
          ),
        );
      }),
    );
  }
}
