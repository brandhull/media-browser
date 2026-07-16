import Foundation
import UniformTypeIdentifiers

struct FolderScanResult {
    let media: [MediaItem]
    let subfolders: [URL]
}

enum FolderScanner {
    static func scan(folder: URL) -> FolderScanResult {
        let resourceKeys: [URLResourceKey] = [
            .contentTypeKey, .fileSizeKey, .creationDateKey,
            .contentModificationDateKey, .contentAccessDateKey, .isDirectoryKey
        ]

        guard let entries = try? FileManager.default.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsHiddenFiles]
        ) else { return FolderScanResult(media: [], subfolders: []) }

        var results: [MediaItem] = []
        var subfolders: [URL] = []

        for url in entries {
            guard let values = try? url.resourceValues(forKeys: Set(resourceKeys)) else { continue }
            if values.isDirectory == true {
                subfolders.append(url)
                continue
            }
            guard let type = values.contentType else { continue }

            let kind: MediaKind
            if type.conforms(to: .image) {
                kind = .image
            } else if type.conforms(to: .movie) || type.conforms(to: .video) {
                kind = .video
            } else {
                continue
            }

            results.append(MediaItem(
                url: url,
                kind: kind,
                name: url.lastPathComponent,
                size: Int64(values.fileSize ?? 0),
                createdDate: values.creationDate,
                modifiedDate: values.contentModificationDate,
                lastOpenedDate: values.contentAccessDate
            ))
        }

        subfolders.sort { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        return FolderScanResult(media: results, subfolders: subfolders)
    }
}
