import Foundation

enum PreviewData {
    static let shelfID = UUID()
    static let book = Book(
        id: UUID(),
        title: "Sample Book",
        author: "Sample Author",
        isbn: "9780000000000",
        notes: "A sample book used for SwiftUI previews.",
        shelfID: shelfID
    )
    static let shelf = Shelf(
        id: shelfID,
        name: "Preview Shelf",
        description: "A shelf for preview purposes.",
        books: [book]
    )
}
