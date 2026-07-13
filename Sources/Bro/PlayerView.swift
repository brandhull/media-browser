import SwiftUI
import AVKit

/// A thin NSViewRepresentable around AppKit's AVPlayerView, used instead of
/// SwiftUI's VideoPlayer — on macOS 26.5.2, VideoPlayer's private
/// _AVKit_SwiftUI bridge crashes on generic metadata instantiation. This
/// avoids that framework entirely.
struct PlayerView: NSViewRepresentable {
    let player: AVPlayer?

    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .floating
        view.player = player
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player !== player {
            nsView.player = player
        }
    }
}
