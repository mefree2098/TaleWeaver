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
            print("Initializing for new character")
            // Initialize with empty values for new character
            _name = State(initialValue: "")
            _description = State(initialValue: "")
            _avatarURL = State(initialValue: "")
            _intelligence = State(initialValue: 5)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Character Image")) {
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
                                    .onTapGesture {
                                        showingFullScreenImage = true
                                    }
                            case .failure:
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Text("No image available")
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        generateAvatar()
                    }) {
                        Label("Generate Avatar", systemImage: "wand.and.stars")
                    }
                    .disabled(description.isEmpty || isGeneratingAvatar)
                }
                
                Section(header: Text("Intelligence Level")) {
                    VStack {
                        HStack {
                            Text("Intelligence: \(intelligence)")
                            Spacer()
                            Text(intelligenceText)
                                .foregroundColor(intelligenceColor)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(intelligence) },
                            set: { intelligence = Int16($0) }
                        ), in: 1...10, step: 1)
                    }
                }
                
                if isGeneratingAvatar {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section {
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
                if let url = URL(string: avatarURL.hasPrefix("http") ? avatarURL : "file://\(avatarURL)") {
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
                    
                    // Ensure state is properly initialized with character data
                    if name.isEmpty && character.name != nil {
                        name = character.name ?? ""
                    }
                    if description.isEmpty && character.characterDescription != nil {
                        description = character.characterDescription ?? ""
                    }
                    if avatarURL.isEmpty && character.avatarURL != nil {
                        avatarURL = character.avatarURL ?? ""
                    }
                    if intelligence == 5 && character.intelligence != 5 {
                        intelligence = character.intelligence
                    }
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
    
    private var intelligenceText: String {
        switch intelligence {
        case 1...3:
            return "Low"
        case 4...6:
            return "Medium"
        case 7...8:
            return "High"
        case 9...10:
            return "Very High"
        default:
            return "Unknown"
        }
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        errorMessage = nil
        
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