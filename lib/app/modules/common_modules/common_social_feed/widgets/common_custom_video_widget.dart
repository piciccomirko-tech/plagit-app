import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/modules/common_modules/common_social_feed/controllers/common_video_controller.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../common/widgets/full_screen_video_widget.dart';

class CommonCustomVideoWidget extends StatelessWidget {
  final Media media;
  final double? height;
  final double? radius;
  final bool? viewAll;
  final void Function()? onTap;

  CommonCustomVideoWidget({
    super.key,
    required this.media,
    this.height,
    this.viewAll,
    this.onTap,
    this.radius,
  });

  final CommonVideoController videoController =
      Get.put(CommonVideoController());

  @override
  Widget build(BuildContext context) {
    final _controller = VideoPlayerController.networkUrl(
      Uri.parse(media.url?.imageUrl ?? ""),
    );

    return FutureBuilder(
      future: videoController.initializeVideo(_controller),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(radius ?? 10.0),
            child: Stack(
              children: [
                _buildVideoPlayer(_controller),
                Obx(() {
                  if (videoController.currentlyPlayingController == null ||
                      !(videoController
                          .currentlyPlayingController!.value.isPlaying)) {
                    return Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildPlayButton(() {
                          videoController.play(_controller);
                        }),
                      ),
                    );
                  }
                  if (videoController.showPauseButton.value) {
                    return Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: _buildPauseButton(() {
                          videoController.pause(_controller);
                        }),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildMuteButton(() {
                    videoController.toggleMute(_controller);
                  }),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: _buildFullscreenButton(() {
                    Get.to(
                        () => FullScreenVideoWidget(videoUrl: media.url ?? ""));
                  }),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Image.asset(
              MyAssets.videoPlayThumbnail,
            ),
          );
        }
      },
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    return SizedBox(
      height: (height != null && height! > 600.h) ? 600.h : height,
      width: Get.width,
      child: VisibilityDetector(
        key: Key(media.url?.imageUrl ?? ""),
        onVisibilityChanged: (visibilityInfo) {
          if (visibilityInfo.visibleFraction * 100 > 50 &&
              videoController.currentlyPlayingController != controller) {
            videoController.play(controller);
          } else if (visibilityInfo.visibleFraction == 0) {
            videoController.pause(controller);
          }
        },
        child: GestureDetector(
          onTap: () {
            if (controller.value.isPlaying) {
              videoController.pause(controller);
            } else {
              videoController.play(controller);
            }
          },
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton(VoidCallback onTap) =>
      _iconButton(CupertinoIcons.play_arrow_solid, onTap);
  Widget _buildPauseButton(VoidCallback onTap) =>
      _iconButton(CupertinoIcons.pause_solid, onTap);
  Widget _buildMuteButton(VoidCallback onTap) => Obx(() {
        return _iconButton(
          videoController.isMuted.value
              ? CupertinoIcons.volume_off
              : CupertinoIcons.volume_up,
          onTap,
          size: 20,
        );
      });
  Widget _buildFullscreenButton(VoidCallback onTap) =>
      _iconButton(CupertinoIcons.fullscreen, onTap, size: 20);

  Widget _iconButton(IconData icon, VoidCallback onTap, {double size = 50}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: MyColors.primaryLight),
    );
  }
}
