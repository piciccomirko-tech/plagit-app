//
//  FeedGalleryViewer.swift
//  Plagit
//
//  Full-screen swipeable photo gallery for multi-image posts.
//

import SwiftUI

struct FeedGalleryViewer: View {
    let images: [UIImage]
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: images.count > 1 ? .always : .never))

                VStack {
                    HStack {
                        if images.count > 1 {
                            Text("\(currentIndex + 1) / \(images.count)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Capsule().fill(.black.opacity(0.5)))
                        }
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32, weight: .medium))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, Color.black.opacity(0.4))
                        }
                    }
                    .padding(20)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear { currentIndex = startIndex }
    }
}
