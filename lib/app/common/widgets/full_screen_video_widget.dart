import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/download_manager.dart';
import 'package:pod_player/pod_player.dart';

import 'custom_appbar_back_button.dart';

class FullScreenVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;

  const FullScreenVideoWidget({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
  });

  @override
  FullScreenVideoWidgetState createState() => FullScreenVideoWidgetState();
}

class FullScreenVideoWidgetState extends State<FullScreenVideoWidget> {
  late PodPlayerController _podController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Change this to your desired color
        statusBarIconBrightness:
        Brightness.light, // Change icons to light or dark
      ));
    });
    _podController = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(widget.videoUrl.socialMediaUrl),
    )..initialise();

  }

  @override
  void dispose() {
    _podController.dispose();
    super.dispose();
  }

  void _downloadCurrentMedia() async {
    DownloadManager.downloadAndSaveMedia(
      mediaUrl: widget.videoUrl.socialMediaUrl,
      mediaType: "video",
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: CustomAppbar.appbar(
      //   title: "",
      //   context: context,
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.download,
      //         color: MyColors.c_C6A34F,
      //       ),
      //       onPressed: _downloadCurrentMedia,
      //     ),
      //   ],
      // ),
      // body: PodVideoPlayer(
      //     frameAspectRatio: widget.aspectRatio,
      //     videoAspectRatio: widget.aspectRatio,
      //     controller: _podController,
      //     alwaysShowProgressBar: true,
      //     matchVideoAspectRatioToFrame: true,
      //     matchFrameAspectRatioToVideo: true),
      body: Stack(
        children: [
          PodVideoPlayer(
              frameAspectRatio: widget.aspectRatio,
              videoAspectRatio: widget.aspectRatio,
              controller: _podController,
              alwaysShowProgressBar: true,
              matchVideoAspectRatioToFrame: true,
              matchFrameAspectRatioToVideo: true),
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 16.w + Get.mediaQuery.padding.top,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomAppbarBackButton(onPressed: () => Get.back()),
                // InkWell(
                //   onTap: _downloadCurrentMedia,
                //   child: Icon(
                //     Icons.download,
                //     color: MyColors.c_C6A34F,
                //     size: 24.r,
                //   ),
                // ),
              ],
            ),
          ),
          Positioned(
            right: 12.w,
            bottom: Get.height*.15,
            child: InkWell(
              onTap: _downloadCurrentMedia,
              child: Icon(
                Icons.download,
                color: MyColors.c_C6A34F,
                size: 24.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
