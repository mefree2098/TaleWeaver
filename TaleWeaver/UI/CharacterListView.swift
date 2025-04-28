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

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        HStack {
            if let avatarURL = character.avatarURL,
               let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .accessibilityLabel("Character avatar")
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Default character avatar")
            }
            
            VStack(alignment: .leading) {
                Text(character.name ?? "")
                    .font(.headline)
                    .accessibilityLabel("Character name")
                
                if let description = character.characterDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .accessibilityLabel("Character description")
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct CharacterListView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterListView(viewModel: CharacterViewModel(context: PersistenceController.shared.container.viewContext))
    }
} 