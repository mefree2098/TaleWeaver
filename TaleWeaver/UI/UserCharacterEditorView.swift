import SwiftUI
import CoreData

struct UserCharacterEditorViewNew: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CharacterViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var avatarURL = ""
    @State private var showingFullScreenImage = false
    @State private var isGeneratingAvatar = false
    @State private var showingDeleteConfirmation = false
    @State private var errorMessage: String?
    
    var character: Character?
    
    init(character: Character? = nil) {
        self.character = character
        _viewModel = StateObject(wrappedValue: CharacterViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Avatar")) {
                    if !avatarURL.isEmpty {
                        AsyncImage(url: URLUtils.createURL(from: avatarURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .onTapGesture {
                                        showingFullScreenImage = true
                                    }
                            case .failure:
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Button("Generate Avatar") {
                        generateAvatar()
                    }
                    .disabled(isGeneratingAvatar || name.isEmpty)
                    
                    if isGeneratingAvatar {
                        ProgressView()
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if character != nil {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Character", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(character == nil ? "New Character" : "Edit Character")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCharacter()
                    }
                }
            }
            .sheet(isPresented: $showingFullScreenImage) {
                if let url = URLUtils.createURL(from: avatarURL) {
                    FullScreenImageView(imageURL: url)
                }
            }
            .alert("Delete Character", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteCharacter()
                }
            } message: {
                Text("Are you sure you want to delete this character? This action cannot be undone and may break any stories associated with this character.")
            }
            .onAppear {
                if let character = character {
                    name = character.name ?? ""
                    description = character.characterDescription ?? ""
                    avatarURL = character.avatarURL ?? ""
                }
            }
        }
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        Task {
            do {
                let characterId = character?.id?.uuidString ?? UUID().uuidString
                let url = try await OpenAIService.shared.generateCharacterAvatar(
                    description: description,
                    characterId: characterId
                )
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                print("Error generating avatar: \(error)")
                await MainActor.run {
                    errorMessage = "Failed to generate avatar: \(error.localizedDescription)"
                    isGeneratingAvatar = false
                }
            }
        }
    }
    
    private func saveCharacter() {
        if let character = character {
            character.name = name
            character.characterDescription = description
            character.avatarURL = avatarURL
            character.isUserCharacter = true
        } else {
            let newCharacter = Character(context: viewContext)
            newCharacter.id = UUID()
            newCharacter.name = name
            newCharacter.characterDescription = description
            newCharacter.avatarURL = avatarURL
            newCharacter.isUserCharacter = true
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving character: \(error)")
            errorMessage = "Failed to save character: \(error.localizedDescription)"
        }
    }
    
    private func deleteCharacter() {
        guard let character = character else { return }
        
        // Delete the character avatar if it exists
        if let characterId = character.id?.uuidString {
            try? OpenAIService.shared.deleteCharacterAvatar(characterId: characterId)
        }
        
        // Delete the character from Core Data
        viewContext.delete(character)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting character: \(error)")
            errorMessage = "Failed to delete character: \(error.localizedDescription)"
        }
    }
} 