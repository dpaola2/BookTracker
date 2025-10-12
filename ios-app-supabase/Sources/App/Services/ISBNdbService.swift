import Foundation

final class ISBNdbService: ISBNdbServicing {
    struct APIError: Error {}

    func lookup(isbn: String) async throws -> ISBNdbMetadata? {
        guard let url = URL(string: "https://api2.isbndb.com/book/\(isbn)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.addValue(AppConstants.isbnDbAPIKey, forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return nil
        }

        let decoded = try JSONDecoder().decode(ISBNdbResponse.self, from: data)
        guard let book = decoded.book else { return nil }

        return ISBNdbMetadata(
            title: book.title,
            author: book.authors?.first ?? "",
            description: book.synopses?.first ?? book.synopsis,
            coverURL: book.image.flatMap(URL.init(string:))
        )
    }

    private struct ISBNdbResponse: Decodable {
        let book: Book?

        struct Book: Decodable {
            let title: String
            let authors: [String]?
            let synopsis: String?
            let synopses: [String]?
            let image: String?
        }
    }
}
