//
//  FeedVideoPlayerView.swift
//  Plagit
//
//  Full-screen video player for community feed video posts.
//

import SwiftUI
import AVKit

struct FeedVideoPlayerView: View {
    let videoUrl: String
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else if let error {
                VStack(spacing: PlagitSpacing.lg) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36)).foregroundColor(.plagitAmber)
                    Text(error)
                        .font(PlagitFont.body()).foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }.padding(PlagitSpacing.xxl)
            } else {
                ProgressView().tint(.white)
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(.white, .black.opacity(0.5))
                    }
                    .padding(PlagitSpacing.xl)
                }
                Spacer()
            }
        }
        .task { await preparePlayer() }
        .onDisappear { player?.pause(); player = nil }
    }

    @MainActor
    private func preparePlayer() async {
        // Base64 data URI — decode to temp file
        if videoUrl.hasPrefix("data:video/") {
            guard let range = videoUrl.range(of: ";base64,") else {
                error = "Invalid video format."
                return
            }
            let base64 = String(videoUrl[range.upperBound...])
            guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
                error = "Could not decode video data."
                return
            }
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
            do {
                try data.write(to: tempUrl)
                let avPlayer = AVPlayer(url: tempUrl)
                player = avPlayer
                avPlayer.play()
            } catch {
                self.error = "Could not prepare video for playback."
            }
            return
        }

        // HTTP(S) URL
        if videoUrl.hasPrefix("http"), let url = URL(string: videoUrl) {
            let avPlayer = AVPlayer(url: url)
            player = avPlayer
            avPlayer.play()
            return
        }

        // Demo placeholder
        if videoUrl == "demo_video" {
            error = "This video will be available after upload processing."
            return
        }

        error = "Video unavailable."
    }
}
