import SwiftUI
import CoreData

enum CharacterEditorMode {
    case create
    case edit(Character)
}

struct CharacterEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
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
            .navigationTitle(character == nil ? "New Character" : "Edit Character")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCharacter()
                }
                .disabled(name.isEmpty)
            )
            .sheet(isPresented: $showingImagePicker) {
                CharacterImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveCharacter() {
        if let character = character {
            viewModel.updateCharacter(character, name: name, description: description, avatarURL: avatarURL)
        } else {
            let _ = viewModel.createCharacter(name: name, description: description, avatarURL: avatarURL, isUserCharacter: false)
        }
        dismiss()
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        Task {
            do {
                let characterId = character?.id?.uuidString ?? UUID().uuidString
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

struct CharacterEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterEditorView(viewModel: CharacterViewModel(context: PersistenceController.shared.container.viewContext))
    }
} 