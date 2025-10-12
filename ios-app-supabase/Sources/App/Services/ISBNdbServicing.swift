import Foundation

protocol ISBNdbServicing {
    func lookup(isbn: String) async throws -> ISBNdbMetadata?
}

struct ISBNdbMetadata: Equatable {
    let title: String
    let author: String
    let description: String?
    let coverURL: URL?
}
