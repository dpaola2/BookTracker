import Foundation
import Combine

final class PreviewSupabaseService: AuthServiceProtocol, LibraryServiceProtocol {
    private let userSubject = CurrentValueSubject<AppUser?, Never>(AppUser(id: UUID().uuidString, email: "preview@example.com"))
    private var shelves: [Shelf]

    init() {
        let shelfID = UUID()
        shelves = [
            Shelf(
                id: shelfID,
                name: "Favorites",
                description: "Books I love",
                books: [
                    Book(
                        id: UUID(),
                        title: "The Pragmatic Programmer",
                        author: "Andrew Hunt",
                        isbn: "9780201616224",
                        notes: "Classic software craftsmanship.",
                        shelfID: shelfID
                    )
                ]
            ),
            Shelf(
                id: UUID(),
                name: "To Read",
                description: "Upcoming reads",
                books: []
            )
        ]
    }

    var userPublisher: AnyPublisher<AppUser?, Never> {
        userSubject.eraseToAnyPublisher()
    }

    func signIn(email: String, password: String) async throws {
        userSubject.send(AppUser(id: UUID().uuidString, email: email))
    }

    func signUp(email: String, password: String) async throws {
        userSubject.send(AppUser(id: UUID().uuidString, email: email))
    }

    func signOut() async throws {
        userSubject.send(nil)
    }

    func fetchShelves() async throws -> [Shelf] {
        shelves
    }

    func fetchBooks(in shelfID: UUID?) async throws -> [Book] {
        if let shelfID {
            return shelves.first(where: { $0.id == shelfID })?.books ?? []
        }
        return shelves.flatMap { $0.books }
    }

    func createBook(_ input: NewBookInput) async throws -> Book {
        let book = Book(
            id: UUID(),
            title: input.title,
            author: input.author,
            isbn: input.isbn,
            notes: input.notes,
            shelfID: input.shelfID
        )
        if let index = shelves.firstIndex(where: { $0.id == input.shelfID }) {
            shelves[index].books.append(book)
        }
        return book
    }

    func deleteBook(_ book: Book) async throws {
        if let shelfIndex = shelves.firstIndex(where: { $0.id == book.shelfID }) {
            shelves[shelfIndex].books.removeAll { $0.id == book.id }
        }
    }
}

struct PreviewISBNdbService: ISBNdbServicing {
    func lookup(isbn: String) async throws -> ISBNdbMetadata? {
        ISBNdbMetadata(
            title: "Sample Book",
            author: "Sample Author",
            description: "A preview description for the book.",
            coverURL: URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg")
        )
    }
}
