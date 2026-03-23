import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CommonVideoController extends GetxController {
  VideoPlayerController? currentlyPlayingController;
  RxBool showPauseButton = false.obs;
  RxBool isMuted = false.obs;

  Future<void> initializeVideo(VideoPlayerController controller) async {
    await controller.initialize();
    controller.setLooping(true);
    await controller.pause();
  }

  void play(VideoPlayerController controller) {
    currentlyPlayingController?.pause();
    currentlyPlayingController = controller;
    controller.play();
  }

  void pause(VideoPlayerController controller) {
    controller.pause();
    if (currentlyPlayingController == controller) {
      currentlyPlayingController = null;
    }
  }

  void toggleMute(VideoPlayerController controller) {
    isMuted.value = !isMuted.value;
    controller.setVolume(isMuted.value ? 0 : 1);
  }
}
