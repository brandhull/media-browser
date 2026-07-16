import SwiftUI

struct FolderTileView: View {
    let url: URL
    let onOpen: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.12))

                GeometryReader { geo in
                    Image(systemName: "folder.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.blue)
                        .frame(width: geo.size.width * 0.4, height: geo.size.height * 0.4)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
            .aspectRatio(4.0 / 3.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(6)
        .contentShape(Rectangle())
        .onTapGesture { onOpen() }
    }
}
