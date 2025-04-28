import SwiftUI
import CoreData

struct StoryCharacterListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let story: Story
    @State private var searchText = ""
    @State private var selectedCharacter: Character?
    @State private var showingCharacterEditor = false
    @State private var refreshID = UUID()
    @State private var showingDeleteConfirmation = false
    
    private var filteredCharacters: [Character] {
        let characters = story.characters?.allObjects as? [Character] ?? []
        let nonUserCharacters = characters.filter { !$0.isUserCharacter }
        if searchText.isEmpty {
            return nonUserCharacters
        }
        return nonUserCharacters.filter { character in
            character.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    private var userCharacters: [Character] {
        let fetchRequest: NSFetchRequest<Character> = Character.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isUserCharacter == YES")
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Characters")) {
                    ForEach(userCharacters, id: \.objectID) { character in
                        HStack {
                            if let avatarURL = character.avatarURL {
                                AsyncImage(url: URL(string: avatarURL.hasPrefix("http") ? avatarURL : "file://\(avatarURL)")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(character.name ?? "")
                                if let description = character.characterDescription {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if story.characters?.contains(character) ?? false {
                                Button("Remove") {
                                    removeCharacter(character)
                                }
                                .foregroundColor(.red)
                            } else {
                                Button("Assign") {
                                    assignCharacter(character)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Story Characters")) {
                    ForEach(filteredCharacters, id: \.objectID) { character in
                        HStack {
                            if let avatarURL = character.avatarURL {
                                AsyncImage(url: URL(string: avatarURL.hasPrefix("http") ? avatarURL : "file://\(avatarURL)")) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                    case .failure:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(character.name ?? "")
                                if let description = character.characterDescription {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button("Edit") {
                                selectedCharacter = character
                                showingCharacterEditor = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .onDelete(perform: deleteCharacters)
                }
            }
            .id(refreshID)
            .searchable(text: $searchText, prompt: "Search characters")
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedCharacter = nil
                        showingCharacterEditor = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCharacterEditor, onDismiss: {
                refreshID = UUID()
            }) {
                StoryCharacterEditorViewNew(character: selectedCharacter, story: story)
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert("Delete Character", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    selectedCharacter = nil
                }
                Button("Delete", role: .destructive) {
                    if let character = selectedCharacter {
                        deleteCharacter(character)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this character? This action cannot be undone and may break any stories associated with this character.")
            }
        }
    }
    
    private func assignCharacter(_ character: Character) {
        let stories = character.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        stories.add(story)
        character.stories = stories
        try? viewContext.save()
        
        refreshID = UUID()
    }
    
    private func removeCharacter(_ character: Character) {
        let stories = character.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        stories.remove(story)
        character.stories = stories
        try? viewContext.save()
        
        refreshID = UUID()
    }
    
    private func deleteCharacters(at offsets: IndexSet) {
        let charactersToDelete = offsets.map { filteredCharacters[$0] }
        
        for character in charactersToDelete {
            selectedCharacter = character
            showingDeleteConfirmation = true
        }
    }
    
    private func deleteCharacter(_ character: Character) {
        let stories = character.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        stories.remove(story)
        character.stories = stories
        
        viewContext.delete(character)
        
        do {
            try viewContext.save()
            refreshID = UUID()
        } catch {
            print("Error deleting character: \(error)")
        }
    }
}

struct StoryCharacterListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryCharacterListView(story: Story())
    }
} 