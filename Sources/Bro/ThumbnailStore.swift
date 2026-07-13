import AppKit
import QuickLookThumbnailing

final class ThumbnailStore {
    static let shared = ThumbnailStore()

    private let cache = NSCache<NSURL, NSImage>()

    func thumbnail(for url: URL, size: CGSize, scale: CGFloat, completion: @escaping (NSImage?) -> Void) {
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }

        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { [weak self] representation, _ in
            let image = representation?.nsImage
            if let image {
                self?.cache.setObject(image, forKey: url as NSURL)
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

@MainActor
final class ThumbnailImageLoader: ObservableObject {
    @Published var image: NSImage?

    func load(url: URL, size: CGSize = CGSize(width: 320, height: 240)) {
        image = nil
        ThumbnailStore.shared.thumbnail(for: url, size: size, scale: 2) { [weak self] img in
            self?.image = img
        }
    }
}
