import SwiftUI

struct ShelvesView: View {
    @StateObject private var viewModel: ShelvesViewModel
    @Environment(\.appEnvironment) private var environment
    let onLogout: () -> Void
    let userEmail: String

    init(viewModel: @autoclosure @escaping () -> ShelvesViewModel, userEmail: String, onLogout: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel())
        self.userEmail = userEmail
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.shelves.isEmpty {
                    ProgressView()
                } else if !viewModel.shelves.isEmpty {
                    List(viewModel.shelves) { shelf in
                        NavigationLink(destination: ShelfDetailView(viewModel: ShelfDetailViewModel(shelf: shelf, libraryService: environment.libraryService))) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(shelf.name)
                                    .font(.headline)
                                if let description = shelf.description, !description.isEmpty {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Text("\(shelf.books.count) books")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                } else {
                    EmptyStateView(
                        title: "No Shelves",
                        message: "Create shelves in Supabase to start tracking your books.",
                        systemImage: "books.vertical"
                    )
                }
            }
            .navigationTitle("Shelves")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out", action: onLogout)
                }
            }
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .alert("Error", isPresented: errorBinding, actions: {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.errorMessage = nil } }
        )
    }
}

struct ShelvesView_Previews: PreviewProvider {
    static var previews: some View {
        ShelvesView(viewModel: ShelvesViewModel(libraryService: PreviewSupabaseService()), userEmail: "preview@example.com", onLogout: {})
            .environment(\.appEnvironment, .preview)
    }
}
