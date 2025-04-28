import SwiftUI
import CoreData

struct StoryCharacterEditorViewNew: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let character: Character?
    let story: Story
    
    @State private var name: String
    @State private var description: String
    @State private var avatarURL: String
    @State private var showingFullScreenImage = false
    @State private var isGeneratingAvatar = false
    @State private var errorMessage: String?
    
    init(character: Character? = nil, story: Story) {
        print("StoryCharacterEditorViewNew init")
        print("Character passed in: \(String(describing: character))")
        print("Character name: \(String(describing: character?.name))")
        print("Character objectID: \(String(describing: character?.objectID))")
        print("Story: \(String(describing: story))")
        
        self.character = character
        self.story = story
        
        // Initialize state with character values if available
        if let character = character {
            print("Initializing with existing character")
            print("Character details:")
            print("- name: \(character.name ?? "nil")")
            print("- description: \(character.characterDescription ?? "nil")")
            print("- avatarURL: \(character.avatarURL ?? "nil")")
            print("- isUserCharacter: \(character.isUserCharacter)")
            print("- stories count: \(character.stories?.count ?? 0)")
            
            _name = State(initialValue: character.name ?? "")
            _description = State(initialValue: character.characterDescription ?? "")
            _avatarURL = State(initialValue: character.avatarURL ?? "")
        } else {
            print("Initializing new character")
            _name = State(initialValue: "")
            _description = State(initialValue: "")
            _avatarURL = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                        .onChange(of: name) { oldValue, newValue in
                            print("Name changed to: \(newValue)")
                        }
                    TextEditor(text: $description)
                        .frame(minHeight: 100, maxHeight: 200)
                        .onChange(of: description) { oldValue, newValue in
                            print("Description changed to: \(newValue)")
                        }
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
                                    .frame(maxWidth: .infinity, maxHeight: 200)
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
                print("StoryCharacterEditorViewNew onAppear")
                print("Current state:")
                print("- name: \(name)")
                print("- description: \(description)")
                print("- avatarURL: \(avatarURL)")
                
                if let character = character {
                    print("Character data on appear:")
                    print("- name: \(character.name ?? "nil")")
                    print("- description: \(character.characterDescription ?? "nil")")
                    print("- avatarURL: \(character.avatarURL ?? "nil")")
                    print("- objectID: \(character.objectID)")
                    print("- isUserCharacter: \(character.isUserCharacter)")
                    print("- stories count: \(character.stories?.count ?? 0)")
                } else {
                    print("No character data available")
                }
            }
        }
    }
    
    private func generateAvatar() {
        guard !name.isEmpty else { return }
        
        Task { @MainActor in
            isGeneratingAvatar = true
            errorMessage = nil
            
            do {
                let description = "A character named \(name). \(self.description)"
                print("Generating avatar with description: \(description)")
                let url = try await OpenAIService.shared.generateCharacterAvatar(description: description)
                print("Avatar generated successfully: \(url)")
                avatarURL = url
                isGeneratingAvatar = false
            } catch OpenAIError.invalidAPIKey {
                errorMessage = "Please set your OpenAI API key in Settings"
                isGeneratingAvatar = false
            } catch {
                errorMessage = error.localizedDescription
                isGeneratingAvatar = false
            }
        }
    }
    
    private func saveCharacter() {
        print("Saving character")
        print("Current state:")
        print("- name: \(name)")
        print("- description: \(description)")
        print("- avatarURL: \(avatarURL)")
        
        if let character = character {
            print("Updating existing character")
            print("- objectID: \(character.objectID)")
            print("- current name: \(character.name ?? "nil")")
            print("- current description: \(character.characterDescription ?? "nil")")
            print("- current avatarURL: \(character.avatarURL ?? "nil")")
            
            character.name = name
            character.characterDescription = description
            character.avatarURL = avatarURL
            character.isUserCharacter = false
        } else {
            print("Creating new character")
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
            print("Character saved successfully")
            dismiss()
        } catch {
            print("Error saving character: \(error)")
        }
    }
} 