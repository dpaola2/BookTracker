import Foundation

@MainActor
final class ShelfDetailViewModel: ObservableObject {
    @Published private(set) var books: [Book] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let shelf: Shelf
    private let libraryService: LibraryServiceProtocol

    init(shelf: Shelf, libraryService: LibraryServiceProtocol) {
        self.shelf = shelf
        self.libraryService = libraryService
        self.books = shelf.books
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        do {
            books = try await libraryService.fetchBooks(in: shelf.id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
