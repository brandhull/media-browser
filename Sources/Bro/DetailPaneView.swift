import SwiftUI
import AppKit

struct DetailPaneView: View {
    let item: MediaItem?
    let onRename: (MediaItem, String) throws -> Void

    @StateObject private var metadataLoader = MetadataLoader()
    @StateObject private var thumbLoader = ThumbnailImageLoader()
    @State private var editableName: String = ""
    @State private var renameError: String?
    @FocusState private var isNameFieldFocused: Bool

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
        Group {
            if let item {
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

                        TextField("Name", text: $editableName)
                            .textFieldStyle(.plain)
                            .font(.headline)
                            .lineLimit(2)
                            .focused($isNameFieldFocused)
                            .onSubmit { commitRename() }
                            .onChange(of: isNameFieldFocused) { focused in
                                if !focused { commitRename() }
                            }

                        if let renameError {
                            Text(renameError)
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }

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
            } else {
                VStack {
                    Spacer()
                    Text("No Selection")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minWidth: 260, idealWidth: 300, maxWidth: 380, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .onChange(of: item) { newItem in
            guard let newItem else { return }
            editableName = newItem.name
            renameError = nil
            thumbLoader.load(url: newItem.url, size: CGSize(width: 480, height: 360))
            metadataLoader.load(for: newItem)
        }
    }

    private func commitRename() {
        guard let item else { return }
        let trimmed = editableName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != item.name else {
            editableName = item.name
            renameError = nil
            return
        }
        do {
            try onRename(item, trimmed)
            renameError = nil
        } catch {
            editableName = item.name
            renameError = error.localizedDescription
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
