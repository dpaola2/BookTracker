import Foundation

@MainActor
final class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published private(set) var isDeleting = false
    @Published var errorMessage: String?

    private let libraryService: LibraryServiceProtocol

    init(book: Book, libraryService: LibraryServiceProtocol) {
        self.book = book
        self.libraryService = libraryService
    }

    func delete(completion: @escaping () -> Void) {
        Task {
            isDeleting = true
            defer { isDeleting = false }
            do {
                try await libraryService.deleteBook(book)
                completion()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
