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
                    NavigationLink(destination: UserCharacterListView(viewModel: characterViewModel)) {
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
    @ObservedObject var viewModel: CharacterViewModel
    @State private var showingAddCharacter = false
    @State private var searchText = ""
    
    var body: some View {
        List {
            ForEach(filteredCharacters) { character in
                NavigationLink(destination: CharacterEditorView(viewModel: viewModel, character: character)) {
                    CharacterRow(character: character)
                }
            }
            .onDelete(perform: deleteCharacters)
        }
        .navigationTitle("User Character")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddCharacter = true
                }) {
                    Label("Add Character", systemImage: "plus")
                }
                .accessibilityLabel("Add new user character")
            }
        }
        .searchable(text: $searchText, prompt: "Search characters")
        .sheet(isPresented: $showingAddCharacter) {
            UserCharacterEditorViewNew()
        }
    }
    
    private var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return viewModel.userCharacters
        } else {
            return viewModel.userCharacters.filter { character in
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
                        AsyncImage(url: URL(string: avatarURL)) { image in
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
        guard !name.isEmpty else { return }
        
        isGeneratingAvatar = true
        errorMessage = nil
        
        Task {
            do {
                let description = "A character named \(name). \(self.description)"
                let url = try await viewModel.generateCharacterAvatar(name: description)
                
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGeneratingAvatar = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
} 