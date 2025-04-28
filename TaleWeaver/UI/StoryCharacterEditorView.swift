import SwiftUI
import CoreData

struct StoryCharacterEditorViewNew: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CharacterViewModel
    
    @State private var name = ""
    @State private var description = ""
    @State private var avatarURL = ""
    @State private var showingFullScreenImage = false
    @State private var isGeneratingAvatar = false
    @State private var errorMessage: String?
    
    var character: Character?
    var story: Story
    
    init(character: Character? = nil, story: Story) {
        self.character = character
        self.story = story
        _viewModel = StateObject(wrappedValue: CharacterViewModel(context: story.managedObjectContext!))
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
                        AsyncImage(url: URL(string: avatarURL)) { phase in
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
                if let url = URL(string: avatarURL) {
                    FullScreenImageView(imageURL: url)
                }
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
        guard !name.isEmpty else { return }
        
        isGeneratingAvatar = true
        errorMessage = nil
        
        Task {
            do {
                let description = "A character named \(name). \(self.description)"
                let url = try await OpenAIService.shared.generateCharacterAvatar(description: description)
                
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch OpenAIError.invalidAPIKey {
                await MainActor.run {
                    errorMessage = "Please set your OpenAI API key in Settings"
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
    
    private func saveCharacter() {
        if let character = character {
            character.name = name
            character.characterDescription = description
            character.avatarURL = avatarURL
            character.isUserCharacter = false
        } else {
            let newCharacter = Character(context: viewContext)
            newCharacter.id = UUID()
            newCharacter.name = name
            newCharacter.characterDescription = description
            newCharacter.avatarURL = avatarURL
            newCharacter.isUserCharacter = false
            
            // Add to stories relationship
            let stories = newCharacter.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
            stories.add(story)
            newCharacter.stories = stories
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving character: \(error)")
        }
    }
} 