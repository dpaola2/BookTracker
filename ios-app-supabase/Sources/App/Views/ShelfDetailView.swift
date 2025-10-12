import SwiftUI

struct ShelfDetailView: View {
    @StateObject private var viewModel: ShelfDetailViewModel
    @Environment(\.appEnvironment) private var environment

    init(viewModel: @autoclosure @escaping () -> ShelfDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            ForEach(viewModel.books) { book in
                NavigationLink(destination: BookDetailView(viewModel: BookDetailViewModel(book: book, libraryService: environment.libraryService))) {
                    BookRowView(book: book)
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.books.isEmpty {
                ProgressView()
            } else if viewModel.books.isEmpty {
                EmptyStateView(
                    title: "No Books",
                    message: "Add books to this shelf from the New Book tab.",
                    systemImage: "book"
                )
            }
        }
        .navigationTitle(viewModel.shelf.name)
        .task { await viewModel.refresh() }
        .refreshable { await viewModel.refresh() }
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.errorMessage = nil } }
        )
    }
}

struct ShelfDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ShelfDetailView(viewModel: ShelfDetailViewModel(shelf: PreviewData.shelf, libraryService: PreviewSupabaseService()))
        }
        .environment(\.appEnvironment, .preview)
    }
}
