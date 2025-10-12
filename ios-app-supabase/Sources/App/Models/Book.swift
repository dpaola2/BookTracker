import Foundation

struct Book: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var isbn: String
    var notes: String
    var coverURL: URL?
    var shelfID: UUID

    init(id: UUID, title: String, author: String, isbn: String, notes: String = "", coverURL: URL? = nil, shelfID: UUID) {
        self.id = id
        self.title = title
        self.author = author
        self.isbn = isbn
        self.notes = notes
        self.coverURL = coverURL
        self.shelfID = shelfID
    }
}

struct NewBookInput {
    var title: String
    var author: String
    var isbn: String
    var notes: String
    var shelfID: UUID
}
