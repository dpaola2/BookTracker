import Foundation
import Supabase

final class SupabaseLibraryService: LibraryServiceProtocol {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchShelves() async throws -> [Shelf] {
        let records: [ShelfRecord] = try await client.database
            .from("shelves")
            .select()
            .order(column: "created_at", ascending: true)
            .execute()
            .value

        var shelves: [Shelf] = []
        for record in records {
            let books = try await fetchBooks(in: record.id)
            shelves.append(
                Shelf(
                    id: record.id,
                    name: record.name,
                    description: record.description,
                    books: books
                )
            )
        }
        return shelves
    }

    func fetchBooks(in shelfID: UUID?) async throws -> [Book] {
        var query = client.database
            .from("books")
            .select()
            .order(column: "created_at", ascending: false)

        if let shelfID {
            query = query.eq("shelf_id", value: shelfID.uuidString)
        }

        let records: [BookRecord] = try await query.execute().value
        return records.map { $0.toModel() }
    }

    func createBook(_ input: NewBookInput) async throws -> Book {
        let insert = BookInsert(
            title: input.title,
            author: input.author,
            isbn: input.isbn,
            notes: input.notes,
            shelfID: input.shelfID
        )

        let response: [BookRecord] = try await client.database
            .from("books")
            .insert(values: insert, returning: .representation)
            .execute()
            .value

        guard let record = response.first else {
            throw LibraryServiceError.unexpectedResponse
        }

        return record.toModel()
    }

    func deleteBook(_ book: Book) async throws {
        _ = try await client.database
            .from("books")
            .delete()
            .eq("id", value: book.id.uuidString)
            .execute()
    }
}

private struct ShelfRecord: Decodable {
    let id: UUID
    let name: String
    let description: String?
}

private struct BookRecord: Codable {
    let id: UUID
    let title: String
    let author: String
    let isbn: String
    let notes: String?
    let cover_url: String?
    let shelf_id: UUID

    func toModel() -> Book {
        Book(
            id: id,
            title: title,
            author: author,
            isbn: isbn,
            notes: notes ?? "",
            coverURL: cover_url.flatMap(URL.init(string:)),
            shelfID: shelf_id
        )
    }
}

private struct BookInsert: Encodable {
    let title: String
    let author: String
    let isbn: String
    let notes: String
    let shelfID: UUID

    enum CodingKeys: String, CodingKey {
        case title
        case author
        case isbn
        case notes
        case shelfID = "shelf_id"
    }
}

enum LibraryServiceError: Error {
    case unexpectedResponse
}
