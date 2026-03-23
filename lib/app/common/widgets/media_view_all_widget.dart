import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/circle_slider_indicator_widget.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_image_widget.dart';
import 'package:mh/app/common/widgets/custom_video_widget.dart';
import 'package:mh/app/common/widgets/download_manager.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:pinch_zoom/pinch_zoom.dart';


class MediaViewAllWidget extends StatefulWidget {
  final List<Media> mediaList;
  final int index;
  const MediaViewAllWidget(
      {super.key, required this.mediaList, required this.index});

  @override
  State<MediaViewAllWidget> createState() => _MediaViewAllWidgetState();
}

class _MediaViewAllWidgetState extends State<MediaViewAllWidget> {
  late CarouselSliderController _carouselSliderController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselSliderController = CarouselSliderController();
    _currentIndex = widget.index;
  }

  void _downloadCurrentMedia() async {
    Media currentMedia = widget.mediaList[_currentIndex];

    DownloadManager.downloadAndSaveMedia(
      mediaUrl: currentMedia.url?.imageUrl ?? "",
      mediaType: currentMedia.type ?? "",
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "",
        context: context,
        actions: [
          IconButton(
            icon: Icon(
              Icons.download,
              color: MyColors.c_C6A34F,
            ),
            onPressed: _downloadCurrentMedia,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CarouselSlider.builder(
                carouselController: _carouselSliderController,
                itemCount: widget.mediaList.length,
                itemBuilder: (context, index, realIndex) {
                  Media media = widget.mediaList[index];
                  Widget mediaWidget;
                  if (media.type == "image") {
                    mediaWidget = PinchZoom(
                      maxScale: 2.5,
                      child: CustomImageWidget(
                        imgUrl: (media.url ?? "").socialMediaUrl,
                        fit: BoxFit.fitWidth,
                        height: Get.height,
                        width: Get.width,
                      ),
                    );
                  } else if (media.type == "video") {
                    mediaWidget = CustomVideoWidget(
                      media: media,
                      radius: 0,
                    );
                  } else {
                    mediaWidget = Container();
                  }

                  return Container(
                    width: Get.width,
                    alignment: Alignment.center,
                    child: mediaWidget,
                  );
                },
                options: CarouselOptions(
                  height: Get.height - 120, // Account for AppBar and indicator
                  enableInfiniteScroll: widget.mediaList.length > 1,
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                  onPageChanged: (int index, CarouselPageChangedReason reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CircleSliderIndicatorWidget(
              currentIndex: _currentIndex,
              itemCount: widget.mediaList.length,
              color: MyColors.c_C6A34F.withOpacity(0.3),
              selectedColor: MyColors.c_C6A34F,
            ),
          ),
        ],
      ),
    );
  }
}

///new
// class MediaViewAllWidget extends StatefulWidget {
//   final List<Media> mediaList;
//   final int index;
//   const MediaViewAllWidget(
//       {super.key, required this.mediaList, required this.index});
//
//   @override
//   State<MediaViewAllWidget> createState() => _MediaViewAllWidgetState();
// }
//
// class _MediaViewAllWidgetState extends State<MediaViewAllWidget> {
//   late CarouselSliderController _carouselSliderController;
//   int _currentIndex = 0;
//   double _dragStartY = 0.0;
//   bool _isCaptionVisible = true;
//   double _opacity = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _carouselSliderController = CarouselSliderController();
//     _currentIndex = widget.index;
//   }
//
//   void _downloadCurrentMedia() async {
//     Media currentMedia = widget.mediaList[_currentIndex];
//
//     DownloadManager.downloadAndSaveMedia(
//       mediaUrl: currentMedia.url?.imageUrl ?? "",
//       mediaType: currentMedia.type ?? "",
//       context: context,
//     );
//   }
//
//   void _onVerticalDragStart(DragStartDetails details) {
//     _dragStartY = details.globalPosition.dy;
//   }
//
//   void _onVerticalDragUpdate(DragUpdateDetails details) {
//     double dragDistance = details.globalPosition.dy - _dragStartY;
//     double fadeThreshold = 150.0; // Adjust fade sensitivity
//
//     // Reduce opacity as the user drags up or down
//     setState(() {
//       _opacity = 1.0 - (dragDistance.abs() / fadeThreshold).clamp(0.0, 1.0);
//     });
//
//     // If drag distance exceeds threshold, go back
//     if (dragDistance.abs() > fadeThreshold) {
//       Navigator.pop(context);
//     }
//   }
//
//   void _onVerticalDragEnd(DragEndDetails details) {
//     // Reset opacity if user doesn't drag far enough
//     setState(() {
//       _opacity = 1.0;
//     });
//   }
//
//   void _toggleCaptionVisibility() {
//     setState(() {
//       _isCaptionVisible = !_isCaptionVisible;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: AnimatedOpacity(
//           duration: Duration(milliseconds: 200), // Smooth fade animation
//           opacity: _opacity,
//           child: Stack(
//             children: [
//               GestureDetector(
//                 onTap: _toggleCaptionVisibility,
//                 onVerticalDragStart: _onVerticalDragStart,
//                 onVerticalDragUpdate: _onVerticalDragUpdate,
//                 onVerticalDragEnd: _onVerticalDragEnd,
//                 child: SizedBox(
//                   height: Get.height,
//                   width: Get.width,
//                   child: Center(
//                     child: CarouselSlider.builder(
//                       carouselController: _carouselSliderController,
//                       itemCount: widget.mediaList.length,
//                       itemBuilder: (context, index, realIndex) {
//                         Media media = widget.mediaList[index];
//                         Widget mediaWidget;
//                         if (media.type == "image") {
//                           mediaWidget = PinchZoom(
//                             maxScale: 2.5,
//                             child: CustomImageWidget(
//                               imgUrl: (media.url ?? "").socialMediaUrl,
//                               fit: BoxFit.fitWidth,
//                               height: Get.height,
//                               width: Get.width,
//                             ),
//                           );
//                         } else if (media.type == "video") {
//                           mediaWidget = CustomVideoWidget(
//                             media: media,
//                             radius: 0,
//                           );
//                         } else {
//                           mediaWidget = Container();
//                         }
//
//                         return Container(
//                           width: Get.width,
//                           alignment: Alignment.center,
//                           child: mediaWidget,
//                         );
//                       },
//                       options: CarouselOptions(
//                         height:
//                         Get.height - 120, // Account for AppBar and indicator
//                         enableInfiniteScroll: widget.mediaList.length > 1,
//                         autoPlay: false,
//                         enlargeCenterPage: true,
//                         viewportFraction: 1.0,
//                         onPageChanged:
//                             (int index, CarouselPageChangedReason reason) {
//                           setState(() {
//                             _currentIndex = index;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               AnimatedOpacity(
//                 duration: Duration(milliseconds: 300),
//                 opacity: _isCaptionVisible ? 1.0 : 0.0,
//                 child: Padding(
//                   padding: EdgeInsets.only(left: 16.w,right: 16.w,top: 16.w,),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomAppbarBackButton(onPressed: () => Get.back()),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: 12,
//                             backgroundColor: MyColors.noColor,
//                             backgroundImage: AssetImage(MyAssets.clientDefault),
//                           ),
//                           SizedBox(width: 10.w),
//                           Text(
//                             "Italy Job Post",
//                             style: ResponsiveHelper.isTab(Get.context)
//                                 ? MyColors.l111111_dwhite(context).semiBold13
//                                 : MyColors.l111111_dwhite(context).semiBold18,
//                           ),
//                         ],
//                       ),
//                       Icon(Icons.more_vert, size: 24.r, color: MyColors.c_9A9A9A),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 20.h,
//                 left: 16.w,
//                 right: 16.w,
//                 child: AnimatedOpacity(
//                   duration: Duration(milliseconds: 300),
//                   opacity: _isCaptionVisible ? 1.0 : 0.0,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SocialCaptionWidget(
//                         text:
//                         'To go back to the previous screen when the user touches and drags the image, you can use the Dismissible widget or a GestureDetector with a DragUpdateDetails listener.',
//                       ),
//                       SizedBox(height: 12.h),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(CupertinoIcons.hand_thumbsup_fill,
//                                   size: 24.w, color: MyColors.dividerColor),
//                               SizedBox(width: 10.w),
//                               GestureDetector(
//                                 onTap: () {
//                                   // controller.getSocialPostInfoByPostId(
//                                   //     context, socialPost.id);
//                                 },
//                                 child: Text(
//                                   "0",
//                                   style: TextStyle(
//                                     fontFamily: MyAssets.fontMontserrat,
//                                     fontSize: 14,
//                                     color: MyColors.dividerColor,
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                           SizedBox(width: 12.w),
//                           GestureDetector(
//                             onTap: () {
//                               // appUser.isAdmin ? null :
//                               // commentToggle();
//                             },
//                             child: Row(
//                               children: [
//                                 Icon(CupertinoIcons.chat_bubble,
//                                     size: 24.w, color: MyColors.dividerColor),
//                                 SizedBox(width: 10.w),
//                                 Text(
//                                   "0",
//                                   style: TextStyle(
//                                     fontFamily: MyAssets.fontMontserrat,
//                                     fontSize: 14,
//                                     color: MyColors.dividerColor,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 12.w),
//                           Row(
//                             children: [
//                               Icon(Icons.remove_red_eye_outlined,
//                                   size: 24.w, color: MyColors.dividerColor),
//                               SizedBox(width: 10.w),
//                               Text(
//                                 "0",
//                                 style: TextStyle(
//                                   fontFamily: MyAssets.fontMontserrat,
//                                   fontSize: 14,
//                                   color: MyColors.dividerColor,
//                                 ),
//                               )
//                             ],
//                           ),
//                           Spacer(),
//                           GestureDetector(
//                             onTap: () {},
//                             child: Row(
//                               children: [
//                                 Icon(CupertinoIcons.bookmark,
//                                     size: 24.w, color: MyColors.dividerColor),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 12.w),
//                           GestureDetector(
//                             onTap: () {},
//                             child: Row(
//                               children: [
//                                 Icon(CupertinoIcons.repeat,
//                                     size: 24.w, color: MyColors.dividerColor),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
