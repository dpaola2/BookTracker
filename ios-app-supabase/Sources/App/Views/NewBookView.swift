import SwiftUI

struct NewBookView: View {
    @StateObject private var viewModel: NewBookViewModel
    @State private var alertMessage: AlertMessage?

    init(viewModel: @autoclosure @escaping () -> NewBookViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $viewModel.title)
                    TextField("Author", text: $viewModel.author)
                    TextField("ISBN", text: $viewModel.isbn)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                }

                Section("Shelf") {
                    if viewModel.shelves.isEmpty {
                        Text("No shelves available. Create shelves in Supabase.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Shelf", selection: $viewModel.selectedShelfID) {
                            ForEach(viewModel.shelves) { shelf in
                                Text(shelf.name).tag(Optional(shelf.id))
                            }
                        }
                    }
                }

                Section {
                    Button("Lookup ISBN", action: lookupISBN)
                        .disabled(viewModel.isLoading || viewModel.isSaving || viewModel.isbn.isEmpty)
                    Button("Save", action: save)
                        .disabled(viewModel.isSaving)
                }
            }
            .navigationTitle("New Book")
            .task { await viewModel.loadShelves() }
            .onChange(of: viewModel.successMessage) { message in
                guard let message else { return }
                alertMessage = AlertMessage(title: "Success", message: message)
                viewModel.successMessage = nil
            }
            .onChange(of: viewModel.errorMessage) { message in
                guard let message else { return }
                alertMessage = AlertMessage(title: "Error", message: message)
                viewModel.errorMessage = nil
            }
            .alert(item: $alertMessage) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func lookupISBN() {
        Task { await viewModel.lookupISBN() }
    }

    private func save() {
        Task { _ = await viewModel.save() }
    }
}

private struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct NewBookView_Previews: PreviewProvider {
    static var previews: some View {
        NewBookView(viewModel: NewBookViewModel(libraryService: PreviewSupabaseService(), isbnService: PreviewISBNdbService()))
    }
}
