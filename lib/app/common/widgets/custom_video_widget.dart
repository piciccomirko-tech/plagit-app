import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/full_screen_video_widget.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomVideoWidget extends StatefulWidget {
  final Media media;
  final double? height;
  final double? radius;
  final bool? viewAll;
  final bool hasAspect;
  final void Function()? onTap;

  const CustomVideoWidget({
    super.key,
    required this.media,
    this.height,
    this.viewAll,
    this.onTap,
    this.radius,
    this.hasAspect = true,
  });

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  static VideoPlayerController? _currentlyPlayingController;

  bool _showPauseButton = false;
  bool _isMuted = true;
  Timer? _hideButtonTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoFile = File(''); // Replace with: widget.media.getVideoFile();
      if (videoFile.path.isNotEmpty) {
        _controller = VideoPlayerController.file(videoFile);
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.media.url?.socialMediaUrl ?? ''),
        );
      }

      _initializeVideoPlayerFuture = _controller.initialize();
      await _initializeVideoPlayerFuture;

      _controller.setVolume(0);
      setState(() {
        _isInitialized = true;
      });

      await _controller.pause();
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  @override
  void dispose() {
    if (_currentlyPlayingController == _controller) {
      _currentlyPlayingController = null;
    }
    _controller.dispose();
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  void _playVideo() {
    _currentlyPlayingController?.pause();
    setState(() {
      _currentlyPlayingController = _controller;
      _controller.play();
    });
  }

  void _pauseVideo() {
    if (_currentlyPlayingController != null) {
      setState(() {
        _controller.pause();
        if (_currentlyPlayingController == _controller) {
          _currentlyPlayingController = null;
        }
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _pauseVideo();
        _showPauseButton = false;
      } else {
        _playVideo();
        _showPauseButtonTemporarily();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _enterFullscreen() {
    Get.to(() => FullScreenVideoWidget(
          videoUrl: widget.media.url ?? "",
          aspectRatio: _controller.value.aspectRatio,
        ));
  }

  void _showPauseButtonTemporarily() {
    setState(() => _showPauseButton = true);
    _hideButtonTimer?.cancel();
    _hideButtonTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _showPauseButton = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _isInitialized) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
            child: Stack(
              children: [
                widget.hasAspect
                    ? _buildVideoPlayer()
                    : _buildVideoPlayerWithoutAspect(),
                if (!_controller.value.isPlaying)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildPlayButton(),
                    ),
                  ),
                if (_showPauseButton)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildPauseButton(),
                    ),
                  ),
                // Positioned(
                //   top: 50,
                //   right: 16,
                //   child: _buildMuteButton(),
                // ),
                Positioned(
                  bottom: 10,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMuteButton(),
                      SizedBox(height: 30.h),
                      _buildFullscreenButton(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return _buildPlaceholder();
        }
      },
    );
  }

  /// **Grey Placeholder Before Video Loads**
  Widget _buildPlaceholder() {
    double aspectRatio = _isInitialized
        ? _controller.value.aspectRatio
        : widget.media.aspectRatio;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        width: Get.width,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
                widget.media.thumbnail?.socialMediaUrl ?? ''),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Icon(
            CupertinoIcons.play_circle_fill,
            size: 64,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  /*Widget _buildPlaceholder() {
    Future<double> getImageAspectRatio() async {
      final imageProvider = CachedNetworkImageProvider(
          widget.media.thumbnail?.socialMediaUrl ?? ''
      );

      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final Completer<double> completer = Completer<double>();

      // Declare the listener variable first
      late final ImageStreamListener listener;

      listener = ImageStreamListener(
            (ImageInfo imageInfo, bool synchronousCall) {
          final double aspectRatio = imageInfo.image.width / imageInfo.image.height;
          imageStream.removeListener(listener); // Now we can use listener here
          completer.complete(aspectRatio);
        },
        onError: (dynamic exception, StackTrace? stackTrace) {
          completer.complete(16/9); // fallback aspect ratio
        },
      );

      imageStream.addListener(listener);
      return completer.future;
    }

    return FutureBuilder<double>(
      future: getImageAspectRatio(),
      initialData: 16/9,
      builder: (context, snapshot) {
        final aspectRatio = _isInitialized ?
        _controller.value.aspectRatio :
        snapshot.data ?? 16/9;

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    widget.media.thumbnail?.socialMediaUrl ?? ''
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Icon(
                CupertinoIcons.play_circle_fill,
                size: 64,
                color: Colors.white70,
              ),
            ),
          ),
        );
      },
    );
  }*/

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: _buildVideo(),
    );
  }

  Widget _buildVideoPlayerWithoutAspect() {
    return _buildVideo();
  }

  void _handleVisibility(double visiblePercentage) {
    if (visiblePercentage == 0) {
      _pauseVideo();
    } else if (visiblePercentage > 70 &&
        _currentlyPlayingController != _controller) {
      _playVideo();
    }
  }

  Widget _buildVideo() {
    return SizedBox(
      height: (widget.height != null && widget.height! > 600.h)
          ? 600.h
          : widget.height,
      width: Get.width,
      child: VisibilityDetector(
        key: Key(widget.media.url?.imageUrl ?? ""),
        onVisibilityChanged: (visibilityInfo) =>
            _handleVisibility(visibilityInfo.visibleFraction * 100),
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
            child: FittedBox(
              fit: BoxFit.cover,
              alignment: Alignment.center,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() =>
      _iconButton(CupertinoIcons.play_arrow_solid, _togglePlayPause);

  Widget _buildPauseButton() =>
      _iconButton(CupertinoIcons.pause_solid, _togglePlayPause);

  Widget _buildMuteButton() => _iconButton(
        _isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_up,
        _toggleMute,
        size: 20,
      );

  Widget _buildFullscreenButton() =>
      _iconButton(CupertinoIcons.fullscreen, _enterFullscreen, size: 20);

  Widget _iconButton(IconData icon, VoidCallback onTap, {double size = 50}) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: size, color: MyColors.primaryLight),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:mh/app/common/utils/exports.dart';
// import 'package:mh/app/common/widgets/full_screen_video_widget.dart';
// import 'package:mh/app/models/social_feed_response_model.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';
//
// class CustomVideoWidget extends StatefulWidget {
//   final Media media;
//   final double? height;
//   final double? radius;
//   final bool? viewAll;
//   final bool hasAspect;
//   final void Function()? onTap;
//
//   const CustomVideoWidget({
//     super.key,
//     required this.media,
//     this.height,
//     this.viewAll,
//     this.onTap,
//     this.radius,
//     this.hasAspect=true,
//   });
//
//   @override
//   State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
// }
//
// class _CustomVideoWidgetState extends State<CustomVideoWidget> {
//   late VideoPlayerController _controller;
//   late Future<void> _initializeVideoPlayerFuture;
//   static VideoPlayerController? _currentlyPlayingController;
//
//   bool _showPauseButton = false;
//   bool _isMuted = false;
//   Timer? _hideButtonTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializePlayer();
//   }
//
//   // Future<void> _initializePlayer() async {
//   //   try {
//   //     print('_CustomVideoWidgetState._initializePlayer');
//   //     // _controller = VideoPlayerController.networkUrl(
//   //     //   Uri.parse(widget.media.url?.imageUrl ?? ""),
//   //     // );
//   //     _controller = VideoPlayerController.file(
//   //       widget.media.getVideoFile()??File(''),
//   //     );
//   //     _initializeVideoPlayerFuture = _controller.initialize();
//   //     //_controller.setLooping(true);
//   //     await _controller.pause();
//   //   } catch (_) {}
//   // }
//
//
//   Future<void> _initializePlayer() async {
//     try {
//       //print('_CustomVideoWidgetState._initializePlayer');
//       final videoFile =File('') ;//widget.media.getVideoFile();
//       print('_CustomVideoWidgetState._initializePlayer:${videoFile}');
//       if (videoFile.path.isNotEmpty) {
//         _controller = VideoPlayerController.file(videoFile);
//         _initializeVideoPlayerFuture = _controller.initialize();
//         await _controller.pause();
//       } else {
//         print('_CustomVideoWidgetState._initializePlayer:${widget.media.url?.socialMediaUrl??''}');
//         _controller = VideoPlayerController.networkUrl(
//           Uri.parse(widget.media.url?.socialMediaUrl??''),
//         );
//         _initializeVideoPlayerFuture = _controller.initialize();
//         await _controller.pause();
//       }
//     } catch (e) {
//       print('Error initializing video player: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     if (_currentlyPlayingController == _controller) {
//       _currentlyPlayingController = null;
//     }
//     _controller.dispose();
//
//     _hideButtonTimer?.cancel();
//     print('_CustomVideoWidgetState.dispose:${widget.media.url?.socialMediaUrl??''}');
//     super.dispose();
//   }
//
//   void _showPauseButtonTemporarily() {
//     setState(() => _showPauseButton = true);
//     _hideButtonTimer?.cancel();
//     _hideButtonTimer = Timer(const Duration(seconds: 3), () {
//       setState(() => _showPauseButton = false);
//     });
//   }
//
//   void _handleVisibility(double visiblePercentage) {
//     if (visiblePercentage == 0) {
//       print('_CustomVideoWidgetState._handleVisibility');
//       _pauseVideo();
//     } else if (visiblePercentage > 70 &&
//         _currentlyPlayingController != _controller) {
//       print('_CustomVideoWidgetState._handleVisibility2');
//       _playVideo();
//     }
//   }
//
//   void _playVideo() {
//     print('_CustomVideoWidgetState._playVideo:${_currentlyPlayingController}');
//
//     _currentlyPlayingController?.pause();
//     setState(() {
//       _currentlyPlayingController = _controller;
//       _controller.play();
//     });
//   }
//
//   void _pauseVideo() {
//     if (_currentlyPlayingController != null) {
//       setState(() {
//         _controller.pause();
//         if (_currentlyPlayingController == _controller) {
//           _currentlyPlayingController = null;
//         }
//       });
//     }
//   }
//
//   void _togglePlayPause() {
//     setState(() {
//       if (_controller.value.isPlaying) {
//         _pauseVideo();
//         _showPauseButton = false;
//       } else {
//         _playVideo();
//         _showPauseButtonTemporarily();
//       }
//     });
//   }
//
//   void _toggleMute() {
//     setState(() {
//       _isMuted = !_isMuted;
//       _controller.setVolume(_isMuted ? 0 : 1);
//     });
//   }
//
//   void _enterFullscreen() {
//     Get.to(() => FullScreenVideoWidget(videoUrl: widget.media.url ?? ""));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
//             child: Stack(
//               children: [
//                 widget.hasAspect?
//                 _buildVideoPlayer():_buildVideoPlayerWithoutAspect(),
//                 if (!_controller.value.isPlaying)
//                   Positioned.fill(
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: _buildPlayButton(),
//                     ),
//                   ),
//                 if (_showPauseButton)
//                   Positioned.fill(
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: _buildPauseButton(),
//                     ),
//                   ),
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: _buildMuteButton(),
//                 ),
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: _buildFullscreenButton(),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Center(
//             child: Image.asset(
//               MyAssets.videoPlayThumbnail,
//             ),
//           );
//         }
//       },
//     );
//   }
//
//   Widget _buildVideoPlayer() {
//     return AspectRatio(
//       aspectRatio: 1,
//       child: _buildVideo(),
//     );
//   }
//
//   Widget _buildVideoPlayerWithoutAspect() {
//     return _buildVideo();
//   }
//
//   Widget _buildVideo() {
//     return SizedBox(
//       height: (widget.height != null && widget.height! > 600.h)
//           ? 600.h
//           : widget.height,
//       width: Get.width,
//       child: VisibilityDetector(
//         key: Key(widget.media.url?.imageUrl ?? ""),
//         onVisibilityChanged: (visibilityInfo) =>
//             _handleVisibility(visibilityInfo.visibleFraction * 100),
//         child: GestureDetector(
//           onTap: _togglePlayPause,
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
//             child: FittedBox(
//               fit: BoxFit.cover, // Fit video to height and width
//               alignment: Alignment.center,
//               child: SizedBox(
//                 width: _controller.value.size.width,
//                 height: _controller.value.size.height,
//                 child: VideoPlayer(_controller),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlayButton() =>
//       _iconButton(CupertinoIcons.play_arrow_solid, _togglePlayPause);
//
//   Widget _buildPauseButton() =>
//       _iconButton(CupertinoIcons.pause_solid, _pauseVideo);
//
//   Widget _buildMuteButton() => _iconButton(
//         _isMuted ? CupertinoIcons.volume_off : CupertinoIcons.volume_up,
//         _toggleMute,
//         size: 20,
//       );
//
//   Widget _buildFullscreenButton() =>
//       _iconButton(CupertinoIcons.fullscreen, _enterFullscreen, size: 20);
//
//   Widget _iconButton(IconData icon, VoidCallback onTap, {double size = 50}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Icon(icon, size: size, color: MyColors.primaryLight),
//     );
//   }
// }
