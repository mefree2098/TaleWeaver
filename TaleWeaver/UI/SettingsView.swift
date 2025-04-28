import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("openAIAPIKey") private var apiKey: String = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var characterViewModel: CharacterViewModel
    @State private var showingCharacterEditor = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _characterViewModel = StateObject(wrappedValue: CharacterViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("User Character")) {
                    NavigationLink(destination: UserCharacterListView()) {
                        Label("Manage User Character", systemImage: "person")
                    }
                    
                    Button(action: { showingCharacterEditor = true }) {
                        Label("Create User Character", systemImage: "person.badge.plus")
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCharacterEditor) {
                UserCharacterEditorViewNew()
            }
        }
    }
}

struct UserCharacterListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Character.name, ascending: true)],
        predicate: NSPredicate(format: "isUserCharacter == YES"),
        animation: .default)
    private var characters: FetchedResults<Character>
    
    @State private var characterToDelete: Character?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        List {
            ForEach(characters) { character in
                NavigationLink(destination: UserCharacterEditorViewNew(character: character)) {
                    CharacterRow(character: character)
                }
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                characterToDelete = characters[index]
                showingDeleteConfirmation = true
            }
        }
        .navigationTitle("My Characters")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: UserCharacterEditorViewNew()) {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("Delete Character", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                characterToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let character = characterToDelete {
                    deleteCharacter(character)
                }
            }
        } message: {
            Text("Are you sure you want to delete this character? This action cannot be undone.")
        }
    }
    
    private func deleteCharacter(_ character: Character) {
        withAnimation {
            viewContext.delete(character)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting character: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct UserCharacterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CharacterViewModel
    
    private let character: Character?
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var avatarURL: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isGeneratingAvatar = false
    @State private var errorMessage: String?
    
    init(viewModel: CharacterViewModel, character: Character? = nil) {
        self.viewModel = viewModel
        self.character = character
        
        if let character = character {
            _name = State(initialValue: character.name ?? "")
            _description = State(initialValue: character.characterDescription ?? "")
            _avatarURL = State(initialValue: character.avatarURL ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                        .accessibilityLabel("Character name")
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .accessibilityLabel("Character description")
                }
                
                Section(header: Text("Avatar")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .accessibilityLabel("Selected character avatar")
                    } else if let avatarURL = character?.avatarURL, !avatarURL.isEmpty {
                        AsyncImage(url: URLUtils.createURL(from: avatarURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .accessibilityLabel("Character avatar from URL")
                    }
                    
                    HStack {
                        Button(action: {
                            generateAvatar()
                        }) {
                            Label("Generate Avatar", systemImage: "wand.and.stars")
                        }
                        .disabled(name.isEmpty || isGeneratingAvatar)
                        .accessibilityLabel("Generate character avatar")
                    }
                    
                    if isGeneratingAvatar {
                        ProgressView()
                            .accessibilityLabel("Generating avatar")
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .accessibilityLabel("Error: \(error)")
                    }
                }
            }
            .navigationTitle(character == nil ? "New User Character" : "Edit User Character")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCharacter()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func saveCharacter() {
        if let character = character {
            viewModel.updateCharacter(character, name: name, description: description, avatarURL: avatarURL)
        } else {
            let _ = viewModel.createCharacter(name: name, description: description, avatarURL: avatarURL, isUserCharacter: true)
        }
        dismiss()
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        Task {
            do {
                let characterId = UUID().uuidString
                let url = try await viewModel.generateCharacterAvatar(
                    description: description,
                    characterId: characterId
                )
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                print("Error generating avatar: \(error)")
                isGeneratingAvatar = false
            }
        }
    }
}

#Preview {
    SettingsView()
} 