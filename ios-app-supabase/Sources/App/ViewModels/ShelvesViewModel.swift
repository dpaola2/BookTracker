import Foundation

@MainActor
final class ShelvesViewModel: ObservableObject {
    @Published private(set) var shelves: [Shelf] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let libraryService: LibraryServiceProtocol

    init(libraryService: LibraryServiceProtocol) {
        self.libraryService = libraryService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            shelves = try await libraryService.fetchShelves()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
