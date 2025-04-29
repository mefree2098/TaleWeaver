//
// StoryCharacterEditorViewNew.swift
// TaleWeaver
//

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
        self.character = character
        self.story = story
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: Basic Information
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }

                // MARK: Character Image
                Section(header: Text("Character Image")) {
                    if !avatarURL.isEmpty {
                        AsyncImage(url: URLUtils.createURL(from: avatarURL)) { phase in
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

                    Button(action: generateAvatar) {
                        Label("Generate Avatar", systemImage: "wand.and.stars")
                    }
                    .disabled(description.isEmpty || isGeneratingAvatar)

                    if isGeneratingAvatar {
                        ProgressView()
                    }
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // MARK: Intelligence Level
                Section(header: Text("Intelligence Level")) {
                    VStack {
                        HStack {
                            Text("Intelligence: \(intelligence)")
                            Spacer()
                            Text(intelligenceText)
                                .foregroundColor(intelligenceColor)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(intelligence) },
                                set: { intelligence = Int16($0) }
                            ),
                            in: 1...10, step: 1
                        )
                    }
                }
            }
            .navigationTitle(character == nil ? "New Character" : "Edit Character")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveCharacter)
                        .disabled(name.isEmpty)
                }
            }
            .sheet(isPresented: $showingFullScreenImage) {
                if let url = URLUtils.createURL(from: avatarURL) {
                    FullScreenImageView(imageURL: url)
                }
            }
            .onAppear(perform: loadCharacter)
        }
    }

    // MARK: – Load / State Setup
    private func loadCharacter() {
        if let character = character {
            name = character.name ?? ""
            description = character.characterDescription ?? ""
            avatarURL = character.avatarURL ?? ""
            intelligence = character.intelligence
        } else {
            name = ""
            description = ""
            avatarURL = ""
            intelligence = 5
        }
    }

    // MARK: – Avatar Generation
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
                await MainActor.run {
                    errorMessage = "Failed to generate avatar: \(error.localizedDescription)"
                    isGeneratingAvatar = false
                }
            }
        }
    }

    // MARK: – Save Character
    private func saveCharacter() {
        if let existing = character {
            let wasUser = existing.isUserCharacter
            existing.name = name
            existing.characterDescription = description
            existing.avatarURL = avatarURL
            existing.intelligence = intelligence
            existing.isUserCharacter = wasUser
            if !wasUser && !(existing.stories?.contains(story) ?? false) {
                let set = existing.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                set.add(story)
                existing.stories = set
            }
        } else {
            let newChar = Character(context: viewContext)
            newChar.id = UUID()
            newChar.name = name
            newChar.characterDescription = description
            newChar.avatarURL = avatarURL
            newChar.intelligence = intelligence
            newChar.isUserCharacter = false
            let set = NSMutableSet(object: story)
            newChar.stories = set
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save character: \(error.localizedDescription)"
        }
    }

    // MARK: – Helpers
    private var intelligenceColor: Color {
        switch intelligence {
        case 1...3: return .red
        case 4...6: return .orange
        case 7...8: return .yellow
        case 9...10: return .green
        default:     return .blue
        }
    }

    private var intelligenceText: String {
        switch intelligence {
        case 1...3:  return "Low"
        case 4...6:  return "Medium"
        case 7...8:  return "High"
        case 9...10: return "Very High"
        default:     return "Unknown"
        }
    }
}

// MARK: – Preview

struct StoryCharacterEditorViewNew_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let story = Story(context: context)
        story.id = UUID()
        story.title = "Preview Story"

        let character = Character(context: context)
        character.id = UUID()
        character.name = "Sample"
        character.characterDescription = "Sample Desc"
        character.avatarURL = ""
        character.intelligence = 5
        character.isUserCharacter = false

        return StoryCharacterEditorViewNew(character: character, story: story)
            .environment(\.managedObjectContext, context)
    }
}
