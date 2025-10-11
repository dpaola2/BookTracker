import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: BookDetailViewModel

    init(viewModel: @autoclosure @escaping () -> BookDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: viewModel.book.coverURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        Image(systemName: "book")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.book.author)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("ISBN: \(viewModel.book.isbn)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !viewModel.book.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.headline)
                        Text(viewModel.book.notes)
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Book Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive, action: deleteBook) {
                    if viewModel.isDeleting {
                        ProgressView()
                    } else {
                        Image(systemName: "trash")
                    }
                }
                .disabled(viewModel.isDeleting)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private func deleteBook() {
        viewModel.delete {
            dismiss()
        }
    }
}

struct BookDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookDetailView(viewModel: BookDetailViewModel(book: PreviewData.book, libraryService: PreviewSupabaseService()))
        }
    }
}
