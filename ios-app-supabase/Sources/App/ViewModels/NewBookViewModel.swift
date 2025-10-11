import Foundation

@MainActor
final class NewBookViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var author: String = ""
    @Published var isbn: String = ""
    @Published var notes: String = ""
    @Published private(set) var shelves: [Shelf] = []
    @Published var selectedShelfID: UUID?
    @Published private(set) var isLoading = false
    @Published private(set) var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let libraryService: LibraryServiceProtocol
    private let isbnService: ISBNdbServicing

    init(libraryService: LibraryServiceProtocol, isbnService: ISBNdbServicing) {
        self.libraryService = libraryService
        self.isbnService = isbnService
    }

    func loadShelves() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await libraryService.fetchShelves()
            shelves = fetched
            if selectedShelfID == nil {
                selectedShelfID = fetched.first?.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func lookupISBN() async {
        guard !isbn.isEmpty else { return }
        isLoading = true
        do {
            if let metadata = try await isbnService.lookup(isbn: isbn) {
                if title.isEmpty { title = metadata.title }
                if author.isEmpty { author = metadata.author }
                if notes.isEmpty, let description = metadata.description {
                    notes = description
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func save() async -> Bool {
        guard let shelfID = selectedShelfID, !title.isEmpty else {
            errorMessage = "Title and shelf are required"
            return false
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil
        defer { isSaving = false }

        let input = NewBookInput(
            title: title,
            author: author,
            isbn: isbn,
            notes: notes,
            shelfID: shelfID
        )

        do {
            _ = try await libraryService.createBook(input)
            successMessage = "Book added successfully"
            clearForm()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func clearForm() {
        title = ""
        author = ""
        isbn = ""
        notes = ""
    }
}
