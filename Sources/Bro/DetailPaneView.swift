import SwiftUI
import AppKit

struct DetailPaneView: View {
    let item: MediaItem

    @StateObject private var metadataLoader = MetadataLoader()
    @StateObject private var thumbLoader = ThumbnailImageLoader()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private static let byteFormatter: ByteCountFormatter = {
        let f = ByteCountFormatter()
        f.countStyle = .file
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Spacer()
                    Group {
                        if let image = thumbLoader.image {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 180)
                    Spacer()
                }
                .padding(.top, 4)

                Text(item.name)
                    .font(.headline)
                    .textSelection(.enabled)
                    .lineLimit(2)

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Kind", item.kind == .video ? "Video" : "Image")
                    infoRow("Size", Self.byteFormatter.string(fromByteCount: item.size))
                    infoRow("Dimensions", metadataLoader.metadata.dimensions ?? "Loading…")
                    if item.kind == .video {
                        infoRow("Duration", metadataLoader.metadata.duration ?? "Loading…")
                        if let codec = metadataLoader.metadata.codec {
                            infoRow("Codec", codec)
                        }
                        if let frameRate = metadataLoader.metadata.frameRate {
                            infoRow("Frame Rate", frameRate)
                        }
                        if let bitRate = metadataLoader.metadata.bitRate {
                            infoRow("Bit Rate", bitRate)
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Created", item.createdDate.map { Self.dateFormatter.string(from: $0) } ?? "—")
                    infoRow("Modified", item.modifiedDate.map { Self.dateFormatter.string(from: $0) } ?? "—")
                    infoRow("Last Opened", item.lastOpenedDate.map { Self.dateFormatter.string(from: $0) } ?? "—")
                }

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Where")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.url.deletingLastPathComponent().path)
                        .font(.caption)
                        .textSelection(.enabled)
                        .lineLimit(3)
                }

                Button {
                    NSWorkspace.shared.activateFileViewerSelecting([item.url])
                } label: {
                    Label("Show in Finder", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.top, 4)
            }
            .padding(16)
        }
        .frame(minWidth: 260, idealWidth: 300, maxWidth: 380)
        .background(Color(nsColor: .windowBackgroundColor))
        .id(item.id)
        .onAppear {
            thumbLoader.load(url: item.url, size: CGSize(width: 480, height: 360))
            metadataLoader.load(for: item)
        }
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 88, alignment: .leading)
            Text(value)
                .font(.caption)
                .textSelection(.enabled)
            Spacer()
        }
    }
}
