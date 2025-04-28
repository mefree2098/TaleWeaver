import SwiftUI
import CoreData

struct CharacterListView: View {
    @ObservedObject var viewModel: CharacterViewModel
    @State private var showingAddCharacter = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCharacters) { character in
                    NavigationLink(destination: CharacterEditorView(viewModel: viewModel, character: character)) {
                        CharacterRow(character: character)
                    }
                }
                .onDelete(perform: deleteCharacters)
            }
            .navigationTitle("Characters")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCharacter = true
                    }) {
                        Label("Add Character", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new character")
                }
            }
            .searchable(text: $searchText, prompt: "Search characters")
            .sheet(isPresented: $showingAddCharacter) {
                CharacterEditorView(viewModel: viewModel)
            }
        }
    }
    
    private var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return viewModel.characters
        } else {
            return viewModel.characters.filter { character in
                character.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                character.characterDescription?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    private func deleteCharacters(at offsets: IndexSet) {
        for index in offsets {
            let character = filteredCharacters[index]
            viewModel.deleteCharacter(character)
        }
    }
}

struct CharacterListView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListView(viewModel: CharacterViewModel(context: PersistenceController.shared.container.viewContext))
    }
} 