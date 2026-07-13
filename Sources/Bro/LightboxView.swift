import SwiftUI
import AVKit

struct LightboxView: View {
    let item: MediaItem?
    let onClose: () -> Void

    @State private var player: AVPlayer?
    @State private var image: NSImage?

    private var isVisible: Bool { item != nil }

    var body: some View {
        ZStack {
            Color.black.opacity(isVisible ? 0.94 : 0)
                .ignoresSafeArea()
                .onTapGesture { onClose() }

            PlayerView(player: player)
                .padding(48)
                .opacity(item?.kind == .video ? 1 : 0)

            Group {
                if let image, item?.kind == .image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if item?.kind == .image {
                    ProgressView().tint(.white)
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
            .opacity(isVisible ? 1 : 0)
        }
        .allowsHitTesting(isVisible)
        .onExitCommand { if isVisible { onClose() } }
        .onChange(of: item) { newItem in
            player?.pause()
            player = nil
            image = nil

            guard let newItem else { return }

            switch newItem.kind {
            case .video:
                let newPlayer = AVPlayer(url: newItem.url)
                player = newPlayer
                newPlayer.play()
            case .image:
                let url = newItem.url
                Task {
                    let loaded = await Task.detached { NSImage(contentsOf: url) }.value
                    guard item?.url == url else { return }
                    image = loaded
                }
            }
        }
    }
}
