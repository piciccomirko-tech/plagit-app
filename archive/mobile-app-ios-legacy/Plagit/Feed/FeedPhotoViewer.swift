//
//  FeedPhotoViewer.swift
//  Plagit
//
//  Full-screen photo viewer with zoom and swipe-to-dismiss.
//

import SwiftUI

struct PhotoViewerItem: Identifiable {
    let id = UUID()
    let images: [UIImage]
    let startIndex: Int
}

struct PhotoViewerWrapper: View {
    let images: [UIImage]
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var page: Int = 0
    @State private var scale: CGFloat = 1
    @State private var dragY: CGFloat = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .opacity(1.0 - min(abs(dragY) / CGFloat(400), 0.4))

                if images.isEmpty {
                    Text("No image available").foregroundColor(.gray)
                } else if images.count == 1 {
                    zoomableImage(images[0])
                } else {
                    TabView(selection: $page) {
                        ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                            zoomableImage(img)
                                .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .onChange(of: page) { _, _ in
                        withAnimation(.easeOut(duration: 0.15)) { scale = 1 }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if images.count > 1 {
                        Text("\(page + 1) / \(images.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .medium))
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.white.opacity(0.2))
                    }
                }
            }
            .toolbarBackground(.black.opacity(0.6), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear { page = startIndex }
        .preferredColorScheme(.dark)
    }

    private func zoomableImage(_ img: UIImage) -> some View {
        Image(uiImage: img)
            .resizable()
            .scaledToFit()
            .scaleEffect(scale)
            .offset(y: scale <= 1 ? dragY : 0)
            .gesture(
                MagnificationGesture()
                    .onChanged { scale = max($0, 0.5) }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            if scale < 1 { scale = 1 }
                            if scale > 5 { scale = 5 }
                        }
                    }
            )
            .simultaneousGesture(
                scale <= 1 ?
                DragGesture()
                    .onChanged { dragY = $0.translation.height }
                    .onEnded { v in
                        if abs(v.translation.height) > 100 || abs(v.predictedEndTranslation.height) > 250 {
                            dismiss()
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) { dragY = 0 }
                        }
                    }
                : nil
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    scale = scale > 1.1 ? 1 : 2.5
                }
            }
    }
}
