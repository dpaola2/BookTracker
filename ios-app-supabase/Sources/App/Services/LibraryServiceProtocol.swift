import Foundation

protocol LibraryServiceProtocol {
    func fetchShelves() async throws -> [Shelf]
    func fetchBooks(in shelfID: UUID?) async throws -> [Book]
    func createBook(_ input: NewBookInput) async throws -> Book
    func deleteBook(_ book: Book) async throws
}
