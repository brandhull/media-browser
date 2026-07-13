import SwiftUI

struct FolderTileView: View {
    let url: URL
    let size: CGFloat
    let onOpen: () -> Void

    private var cellHeight: CGFloat { size * 0.75 }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.12))

                Image(systemName: "folder.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.blue)
                    .frame(width: size * 0.4)
            }
            .frame(width: size, height: cellHeight)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(width: size)
        }
        .padding(6)
        .contentShape(Rectangle())
        .onTapGesture { onOpen() }
    }
}
