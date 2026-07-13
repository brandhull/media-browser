import SwiftUI
import AppKit

struct MediaGridView: View {
    let items: [MediaItem]
    let subfolders: [URL]
    @Binding var selectedID: URL?
    let thumbnailSize: CGFloat
    let onOpen: (MediaItem) -> Void
    let onNavigate: (URL) -> Void

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: thumbnailSize), spacing: 12)]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(subfolders, id: \.self) { url in
                    FolderTileView(url: url, size: thumbnailSize) { onNavigate(url) }
                        .contextMenu {
                            Button("Open") { onNavigate(url) }
                            Button("Show in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([url])
                            }
                        }
                }

                ForEach(items) { item in
                    ThumbnailCellView(item: item, isSelected: selectedID == item.id, size: thumbnailSize)
                        .onTapGesture(count: 2) { onOpen(item) }
                        .onTapGesture(count: 1) { selectedID = item.id }
                        .contextMenu {
                            Button("Open") { onOpen(item) }
                            Button("Show in Finder") {
                                NSWorkspace.shared.activateFileViewerSelecting([item.url])
                            }
                        }
                }
            }
            .padding(16)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}
