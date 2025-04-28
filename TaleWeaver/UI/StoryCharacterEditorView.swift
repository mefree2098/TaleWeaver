import SwiftUI
import CoreData

struct StoryCharacterEditorViewNew: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let character: Character?
    let story: Story
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var avatarURL: String = ""
    @State private var intelligence: Int16 = 5
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
            print("- intelligence: \(character.intelligence)")
            print("- isUserCharacter: \(character.isUserCharacter)")
            print("- stories count: \(character.stories?.count ?? 0)")
            
            _name = State(initialValue: character.name ?? "")
            _description = State(initialValue: character.characterDescription ?? "")
            _avatarURL = State(initialValue: character.avatarURL ?? "")
            _intelligence = State(initialValue: character.intelligence)
        } else {
            print("Initializing new character")
            _name = State(initialValue: "")
            _description = State(initialValue: "")
            _avatarURL = State(initialValue: "")
            _intelligence = State(initialValue: 5)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                        .onChange(of: name) { oldValue, newValue in
                            print("Name changed from '\(oldValue)' to '\(newValue)'")
                        }
                    TextEditor(text: $description)
                        .frame(minHeight: 100, maxHeight: 200)
                        .onChange(of: description) { oldValue, newValue in
                            print("Description changed from '\(oldValue)' to '\(newValue)'")
                        }
                }
                
                Section(header: Text("Character Traits")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Intelligence")
                            Spacer()
                            Text("\(intelligence)")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: Binding(
                            get: { Double(intelligence) },
                            set: { intelligence = Int16($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(intelligenceColor)
                        .onChange(of: intelligence) { oldValue, newValue in
                            print("Intelligence changed from \(oldValue) to \(newValue)")
                        }
                    }
                }
                
                Section(header: Text("Avatar")) {
                    if !avatarURL.isEmpty {
                        AsyncImage(url: URL(string: avatarURL.hasPrefix("http") ? avatarURL : "file://\(avatarURL)")) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                                    .cornerRadius(10)
                            case .failure:
                                Image(systemName: "person.crop.rectangle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 200)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.rectangle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .foregroundColor(.gray)
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
                print("- name: '\(name)'")
                print("- description: '\(description)'")
                print("- avatarURL: '\(avatarURL)'")
                print("- intelligence: \(intelligence)")
                
                if let character = character {
                    print("Character data on appear:")
                    print("- objectID: \(character.objectID)")
                    print("- name: '\(character.name ?? "nil")'")
                    print("- description: '\(character.characterDescription ?? "nil")'")
                    print("- avatarURL: '\(character.avatarURL ?? "nil")'")
                    print("- intelligence: \(character.intelligence)")
                    print("- isUserCharacter: \(character.isUserCharacter)")
                    print("- stories count: \(character.stories?.count ?? 0)")
                } else {
                    print("No character data available")
                }
            }
        }
    }
    
    private var intelligenceColor: Color {
        switch intelligence {
        case 1...3:
            return .red
        case 4...6:
            return .orange
        case 7...8:
            return .yellow
        case 9...10:
            return .green
        default:
            return .blue
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
        print("Current state before save:")
        print("- name: '\(name)'")
        print("- description: '\(description)'")
        print("- avatarURL: '\(avatarURL)'")
        print("- intelligence: \(intelligence)")
        
        if let existingCharacter = character {
            print("Updating existing character")
            print("Character before update:")
            print("- objectID: \(existingCharacter.objectID)")
            print("- name: '\(existingCharacter.name ?? "nil")'")
            print("- description: '\(existingCharacter.characterDescription ?? "nil")'")
            print("- avatarURL: '\(existingCharacter.avatarURL ?? "nil")'")
            print("- intelligence: \(existingCharacter.intelligence)")
            print("- isUserCharacter: \(existingCharacter.isUserCharacter)")
            print("- stories count: \(existingCharacter.stories?.count ?? 0)")
            
            existingCharacter.name = name
            existingCharacter.characterDescription = description
            existingCharacter.avatarURL = avatarURL
            existingCharacter.intelligence = intelligence
            existingCharacter.isUserCharacter = false
            
            print("Character after update:")
            print("- objectID: \(existingCharacter.objectID)")
            print("- name: '\(existingCharacter.name ?? "nil")'")
            print("- description: '\(existingCharacter.characterDescription ?? "nil")'")
            print("- avatarURL: '\(existingCharacter.avatarURL ?? "nil")'")
            print("- intelligence: \(existingCharacter.intelligence)")
            print("- isUserCharacter: \(existingCharacter.isUserCharacter)")
            print("- stories count: \(existingCharacter.stories?.count ?? 0)")
        } else {
            print("Creating new character")
            let newCharacter = Character(context: viewContext)
            newCharacter.id = UUID()
            newCharacter.name = name
            newCharacter.characterDescription = description
            newCharacter.avatarURL = avatarURL
            newCharacter.intelligence = intelligence
            newCharacter.isUserCharacter = false
            
            // Add to stories relationship
            let stories = newCharacter.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
            stories.add(story)
            newCharacter.stories = stories
            
            print("New character created:")
            print("- objectID: \(newCharacter.objectID)")
            print("- name: '\(newCharacter.name ?? "nil")'")
            print("- description: '\(newCharacter.characterDescription ?? "nil")'")
            print("- avatarURL: '\(newCharacter.avatarURL ?? "nil")'")
            print("- intelligence: \(newCharacter.intelligence)")
            print("- isUserCharacter: \(newCharacter.isUserCharacter)")
            print("- stories count: \(newCharacter.stories?.count ?? 0)")
        }
        
        do {
            try viewContext.save()
            print("Character saved successfully")
            dismiss()
        } catch {
            print("Error saving character: \(error)")
            print("Error details: \(error.localizedDescription)")
            errorMessage = "Failed to save character: \(error.localizedDescription)"
        }
    }
} 