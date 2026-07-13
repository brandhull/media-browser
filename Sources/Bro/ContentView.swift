import SwiftUI
import AppKit

struct ContentView: View {
    @State private var folderStack: [URL] = []
    @State private var items: [MediaItem] = []
    @State private var subfolders: [URL] = []
    @State private var selectedID: URL?
    @State private var sortField: SortField = .name
    @State private var sortAscending = true
    @State private var lightboxItem: MediaItem?
    @State private var isScanning = false
    @State private var thumbnailSize: CGFloat = 160

    private static let lastFolderKey = "lastFolderPath"

    private var folderURL: URL? { folderStack.last }

    private var sortedItems: [MediaItem] {
        MediaSorter.sort(items, field: sortField, ascending: sortAscending)
    }

    private var selectedItem: MediaItem? {
        guard let selectedID else { return nil }
        return items.first { $0.url == selectedID }
    }

    var body: some View {
        VStack(spacing: 0) {
            if folderStack.count > 1 {
                breadcrumbBar
                Divider()
            }

            HSplitView {
                Group {
                    if folderURL == nil {
                        emptyState
                    } else if isScanning {
                        ProgressView("Scanning…")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if items.isEmpty && subfolders.isEmpty {
                        Text("No photos or videos in this folder")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        MediaGridView(
                            items: sortedItems,
                            subfolders: subfolders,
                            selectedID: $selectedID,
                            thumbnailSize: thumbnailSize,
                            onOpen: { item in lightboxItem = item },
                            onNavigate: { url in navigateInto(url) }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(minWidth: 500, maxWidth: .infinity, maxHeight: .infinity)

                if let selectedItem {
                    DetailPaneView(item: selectedItem)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    chooseFolder()
                } label: {
                    Label("Open Folder", systemImage: "folder.badge.plus")
                }

                if folderURL != nil {
                    Picker("Sort by", selection: $sortField) {
                        ForEach(SortField.allCases) { field in
                            Text(field.rawValue).tag(field)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)

                    Button {
                        sortAscending.toggle()
                    } label: {
                        Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                    }
                    .help(sortAscending ? "Ascending" : "Descending")

                    HStack(spacing: 6) {
                        Image(systemName: "photo")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Slider(value: $thumbnailSize, in: 100...360)
                            .frame(width: 100)
                        Image(systemName: "photo")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .help("Thumbnail size")
                }
            }
        }
        .navigationTitle(folderURL?.lastPathComponent ?? "Bro")
        .overlay {
            LightboxView(item: lightboxItem) { self.lightboxItem = nil }
        }
        .onAppear { loadLastFolderIfAvailable() }
    }

    private var breadcrumbBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(Array(folderStack.enumerated()), id: \.offset) { index, url in
                    Button {
                        navigateToBreadcrumb(index: index)
                    } label: {
                        Text(url.lastPathComponent)
                            .font(.callout)
                            .foregroundStyle(index == folderStack.count - 1 ? Color.primary : Color.accentColor)
                    }
                    .buttonStyle(.plain)

                    if index < folderStack.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Open a folder to browse photos and videos")
                .foregroundStyle(.secondary)
            Button("Open Folder…") { chooseFolder() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        folderStack = [url]
        loadCurrentFolder()
    }

    private func navigateInto(_ url: URL) {
        folderStack.append(url)
        loadCurrentFolder()
    }

    private func navigateToBreadcrumb(index: Int) {
        guard index < folderStack.count - 1 else { return }
        folderStack = Array(folderStack.prefix(index + 1))
        loadCurrentFolder()
    }

    private func loadLastFolderIfAvailable() {
        guard folderStack.isEmpty else { return }
        guard let path = UserDefaults.standard.string(forKey: Self.lastFolderKey) else { return }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else { return }
        folderStack = [URL(fileURLWithPath: path)]
        loadCurrentFolder()
    }

    private func loadCurrentFolder() {
        guard let url = folderURL else { return }
        selectedID = nil
        isScanning = true
        UserDefaults.standard.set(url.path, forKey: Self.lastFolderKey)
        Task.detached {
            let scanned = FolderScanner.scan(folder: url)
            await MainActor.run {
                self.items = scanned.media
                self.subfolders = scanned.subfolders
                self.isScanning = false
            }
        }
    }
}
