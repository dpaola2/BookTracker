import SwiftUI

struct MainTabView: View {
    @Environment(\.appEnvironment) private var environment
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var selection = 0

    let user: AppUser

    var body: some View {
        TabView(selection: $selection) {
            ShelvesView(
                viewModel: ShelvesViewModel(libraryService: environment.libraryService),
                userEmail: user.email,
                onLogout: appViewModel.signOut
            )
            .tabItem {
                Label("Shelves", systemImage: "books.vertical")
            }
            .tag(0)

            BooksView(viewModel: BooksViewModel(libraryService: environment.libraryService))
                .tabItem {
                    Label("Books", systemImage: "book")
                }
                .tag(1)

            NewBookView(viewModel: NewBookViewModel(libraryService: environment.libraryService, isbnService: environment.isbnService))
                .tabItem {
                    Label("New Book", systemImage: "plus")
                }
                .tag(2)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: AppUser(id: UUID().uuidString, email: "preview@example.com"))
            .environment(\.appEnvironment, .preview)
            .environmentObject(AppViewModel(environment: .preview))
    }
}
