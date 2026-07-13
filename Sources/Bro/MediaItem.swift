import Foundation

enum MediaKind {
    case image
    case video
}

struct MediaItem: Identifiable, Hashable {
    let url: URL
    let kind: MediaKind
    let name: String
    let size: Int64
    let createdDate: Date?
    let modifiedDate: Date?
    let lastOpenedDate: Date?

    var id: URL { url }

    static func == (lhs: MediaItem, rhs: MediaItem) -> Bool { lhs.url == rhs.url }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

enum SortField: String, CaseIterable, Identifiable {
    case name = "Name"
    case dateCreated = "Date Created"
    case dateModified = "Date Modified"
    case dateLastOpened = "Last Opened"

    var id: String { rawValue }
}

enum MediaSorter {
    static func sort(_ items: [MediaItem], field: SortField, ascending: Bool) -> [MediaItem] {
        let sorted = items.sorted { a, b in
            switch field {
            case .name:
                return a.name.localizedStandardCompare(b.name) == .orderedAscending
            case .dateCreated:
                return (a.createdDate ?? .distantPast) < (b.createdDate ?? .distantPast)
            case .dateModified:
                return (a.modifiedDate ?? .distantPast) < (b.modifiedDate ?? .distantPast)
            case .dateLastOpened:
                return (a.lastOpenedDate ?? .distantPast) < (b.lastOpenedDate ?? .distantPast)
            }
        }
        return ascending ? sorted : sorted.reversed()
    }
}
