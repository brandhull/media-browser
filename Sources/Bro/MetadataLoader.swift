import AVFoundation
import ImageIO
import Foundation

struct DetailMetadata {
    var dimensions: String?
    var duration: String?
    var codec: String?
    var frameRate: String?
    var bitRate: String?
}

@MainActor
final class MetadataLoader: ObservableObject {
    @Published var metadata = DetailMetadata()
    private var currentURL: URL?

    func load(for item: MediaItem) {
        currentURL = item.url
        metadata = DetailMetadata()
        let url = item.url

        switch item.kind {
        case .image:
            Task { [weak self] in
                let dims = await Task.detached { Self.imageDimensions(url) }.value
                guard let self, self.currentURL == url else { return }
                self.metadata.dimensions = dims
            }
        case .video:
            Task { [weak self] in
                let asset = AVURLAsset(url: url)
                do {
                    let duration = try await asset.load(.duration)
                    let tracks = try await asset.loadTracks(withMediaType: .video)
                    var dims: String?
                    var codecStr: String?
                    var frameRateStr: String?
                    var bitRateStr: String?

                    if let track = tracks.first {
                        let size = try await track.load(.naturalSize)
                        let transform = try await track.load(.preferredTransform)
                        let actualSize = size.applying(transform)
                        dims = "\(Int(abs(actualSize.width))) × \(Int(abs(actualSize.height)))"

                        let formatDescriptions = try await track.load(.formatDescriptions)
                        if let desc = formatDescriptions.first {
                            let codecType = CMFormatDescriptionGetMediaSubType(desc)
                            codecStr = Self.fourCCString(codecType)
                        }

                        let nominalFrameRate = try await track.load(.nominalFrameRate)
                        if nominalFrameRate > 0 {
                            frameRateStr = String(format: "%.2f fps", nominalFrameRate)
                        }

                        let dataRate = try await track.load(.estimatedDataRate)
                        if dataRate > 0 {
                            bitRateStr = Self.formatBitRate(dataRate)
                        }
                    }

                    let durationSeconds = CMTimeGetSeconds(duration)
                    guard let self, self.currentURL == url else { return }
                    self.metadata.duration = Self.formatDuration(durationSeconds)
                    self.metadata.dimensions = dims
                    self.metadata.codec = codecStr
                    self.metadata.frameRate = frameRateStr
                    self.metadata.bitRate = bitRateStr
                } catch {
                    // Leave fields blank if metadata can't be read.
                }
            }
        }
    }

    nonisolated static func imageDimensions(_ url: URL) -> String? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = props[kCGImagePropertyPixelWidth] as? Int,
              let height = props[kCGImagePropertyPixelHeight] as? Int else { return nil }
        return "\(width) × \(height)"
    }

    nonisolated static func formatDuration(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "—" }
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    nonisolated static func formatBitRate(_ bitsPerSecond: Float) -> String {
        let mbps = bitsPerSecond / 1_000_000
        if mbps >= 1 {
            return String(format: "%.1f Mbps", mbps)
        }
        return String(format: "%.0f kbps", bitsPerSecond / 1000)
    }

    nonisolated static func fourCCString(_ code: FourCharCode) -> String {
        var result = ""
        for shift in stride(from: 24, through: 0, by: -8) {
            let byte = UInt8((code >> shift) & 0xff)
            result.append(Character(Unicode.Scalar(byte)))
        }
        return result.trimmingCharacters(in: .whitespaces)
    }
}
