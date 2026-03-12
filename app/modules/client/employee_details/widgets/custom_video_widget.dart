import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/*class CustomVideoWidget extends StatelessWidget {
  final String videoUrl;
  const CustomVideoWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoController>(
      init: VideoController(videoUrl: videoUrl),
      builder: (controller) {
        return Container(
            height: Get.width * 0.45,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
            child: controller.chewieController != null &&
                    controller.chewieController!.videoPlayerController.value.isInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                            height: Get.width * 0.45,
                            width: Get.width,
                            child: Chewie(controller: controller.chewieController!))))
                : CustomImageWidget(
                    radius: 10.0,
                    height: Get.width * 0.45,
                    width: double.infinity,
                    imgAssetPath: MyAssets.videoThumbnail));
      },
    );
  }
}*/

class CustomVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double height;

  const CustomVideoWidget({super.key, required this.videoUrl, required this.height});

  @override
  CustomVideoWidgetState createState() => CustomVideoWidgetState();
}

class CustomVideoWidgetState extends State<CustomVideoWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 16 / 9
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
