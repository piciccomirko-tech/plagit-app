import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Placeholder full-screen video player for community feed video posts.
/// Mirrors FeedVideoPlayerView.swift — actual AVKit playback not available in Flutter,
/// so this shows a placeholder with close button.
class FeedVideoPlayerView extends StatelessWidget {
  final String videoUrl;

  const FeedVideoPlayerView({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    final isDemo = videoUrl == 'demo_video' || videoUrl.isEmpty;
    final errorMessage = isDemo
        ? 'This video will be available after upload processing.'
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          Center(
            child: errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 36, color: AppColors.amber),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Video Player',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                        child: Text(
                          'Video playback will be available with the video_player package integration.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ),
                    ],
                  ),
          ),

          // Close button — top right
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.xl,
            right: AppSpacing.xl,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 22, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
