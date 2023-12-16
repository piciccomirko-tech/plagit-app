import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  String videoUrl;

  VideoController({required this.videoUrl});

  @override
  void onInit() {
    initializePlayer(videoUrl: videoUrl);
    super.onInit();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  void initializePlayer({required String videoUrl}) async {
    try {
      print('VideoController.initializePlayer: $videoUrl');
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await Future.wait([videoPlayerController.initialize()]);
      chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: true,
          showControls: true,
          showOptions: true,
          materialProgressColors: ChewieProgressColors(
              playedColor: Colors.blue,
              handleColor: MyColors.c_C6A34F,
              backgroundColor: Colors.transparent,
              bufferedColor: MyColors.white),
          placeholder: Container(
            decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(10.0)),
          ),
          autoInitialize: true);
      update();
    } catch (_) {}
  }
}
