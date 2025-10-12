import Foundation

struct Shelf: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var description: String?
    var books: [Book]

    init(id: UUID, name: String, description: String? = nil, books: [Book] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.books = books
    }
}
