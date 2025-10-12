import Foundation

@MainActor
final class BooksViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published var query: String = "" {
        didSet { filterBooks() }
    }
    @Published private(set) var filteredBooks: [Book] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let libraryService: LibraryServiceProtocol

    init(libraryService: LibraryServiceProtocol) {
        self.libraryService = libraryService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            books = try await libraryService.fetchBooks(in: nil)
            filterBooks()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func filterBooks() {
        guard !query.isEmpty else {
            filteredBooks = books
            return
        }

        let lowercased = query.lowercased()
        filteredBooks = books.filter { book in
            book.title.lowercased().contains(lowercased) ||
            book.author.lowercased().contains(lowercased) ||
            book.isbn.lowercased().contains(lowercased)
        }
    }
}
