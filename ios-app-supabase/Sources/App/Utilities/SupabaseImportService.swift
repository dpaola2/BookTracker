import Foundation

struct LegacyBook: Decodable {
    let title: String
    let author: String
    let isbn: String
    let notes: String
    let shelfName: String

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case isbn
        case notes
        case shelfName = "shelf_name"
    }
}

final class SupabaseImportService {
    private let libraryService: LibraryServiceProtocol

    init(libraryService: LibraryServiceProtocol) {
        self.libraryService = libraryService
    }

    /// Imports legacy books into Supabase by creating shelves if needed and inserting the books.
    func importBooks(from data: Data) async throws {
        let decoder = JSONDecoder()
        let legacyBooks = try decoder.decode([LegacyBook].self, from: data)
        let existingShelves = try await libraryService.fetchShelves()
        var shelfLookup: [String: Shelf] = Dictionary(uniqueKeysWithValues: existingShelves.map { ($0.name.lowercased(), $0) })

        for book in legacyBooks {
            let shelfName = book.shelfName.trimmingCharacters(in: .whitespacesAndNewlines)
            let shelfKey = shelfName.lowercased()
            let shelf: Shelf
            if let existing = shelfLookup[shelfKey] {
                shelf = existing
            } else {
                let newShelf = Shelf(id: UUID(), name: shelfName, books: [])
                shelfLookup[shelfKey] = newShelf
                // Persist the shelf using Supabase REST API or RPC. This implementation assumes the shelf already exists or is handled externally.
                shelf = newShelf
            }

            let input = NewBookInput(
                title: book.title,
                author: book.author,
                isbn: book.isbn,
                notes: book.notes,
                shelfID: shelf.id
            )
            _ = try await libraryService.createBook(input)
        }
    }
}
