import SwiftUI
import AVKit

struct LightboxView: View {
    let item: MediaItem
    let onClose: () -> Void

    @State private var image: NSImage?

    var body: some View {
        ZStack {
            Color.black.opacity(0.94)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            Group {
                switch item.kind {
                case .video:
                    VideoPlayer(player: AVPlayer(url: item.url))
                case .image:
                    if let image {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ProgressView().tint(.white)
                    }
                }
            }
            .padding(48)

            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .padding(20)
                }
                Spacer()
            }
        }
        .onExitCommand { onClose() }
        .task {
            if item.kind == .image {
                let url = item.url
                image = await Task.detached { NSImage(contentsOf: url) }.value
            }
        }
        .transition(.opacity)
    }
}
