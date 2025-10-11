import SwiftUI

struct BooksView: View {
    @StateObject private var viewModel: BooksViewModel
    @Environment(\.appEnvironment) private var environment

    init(viewModel: @autoclosure @escaping () -> BooksViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            List(viewModel.filteredBooks) { book in
                NavigationLink(destination: BookDetailView(viewModel: BookDetailViewModel(book: book, libraryService: environment.libraryService))) {
                    BookRowView(book: book)
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.filteredBooks.isEmpty {
                    ProgressView()
                } else if viewModel.filteredBooks.isEmpty {
                    EmptyStateView(
                        title: "No Books",
                        message: "Add books to Supabase to see them here.",
                        systemImage: "text.book.closed"
                    )
                }
            }
            .navigationTitle("Books")
            .searchable(text: $viewModel.query, prompt: "Search by title, author, or ISBN")
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .alert("Error", isPresented: errorBinding) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.errorMessage = nil } }
        )
    }
}

struct BooksView_Previews: PreviewProvider {
    static var previews: some View {
        BooksView(viewModel: BooksViewModel(libraryService: PreviewSupabaseService()))
            .environment(\.appEnvironment, .preview)
    }
}
