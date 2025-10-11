import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: book.coverURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 48, height: 72)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
            .frame(width: 48, height: 72)

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("ISBN: \(book.isbn)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemFill))
            .frame(width: 48, height: 72)
            .overlay {
                Image(systemName: "book")
                    .foregroundColor(.secondary)
            }
    }
}

struct BookRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookRowView(book: PreviewData.book)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
