import SwiftUI
import CoreData

struct SceneDetailView: View {
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    let scene: Scene
    let story: Story

    @State private var newMessageText = ""
    @State private var isAdding = false
    @State private var showingCharacterList = false
    @State private var showingDeleteConfirm = false

    // Track characters before opening picker
    @State private var prePickerCharacters: Set<Character> = []

    // Computed list of characters assigned to the story
    private var characterList: [Character] {
        let set = story.characters as? Set<Character> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Character chips
                    if !characterList.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(characterList, id: \.objectID) { char in
                                    CharacterChip(character: char, removeAction: removeCharacter(_:))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    Text(scene.title ?? "Untitled")
                        .font(.title)
                    if let sum = scene.summary {
                        Text(sum).font(.body)
                    }
                    if scene.promptsArray.isEmpty {
                        Button {
                            newMessageText = ""
                        } label: {
                            Label("Start Chat", systemImage: "bubble.left.fill")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Divider()
                    // Chat transcript
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(scene.promptsArray) { prompt in
                            ChatMessageView(prompt: prompt, userCharacter: story.userCharacter)
                        }
                    }
                }
                .padding()
            }
            chatBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    prePickerCharacters = Set(story.characters as? Set<Character> ?? [])
                    showingCharacterList = true
                }) {
                    Image(systemName: "person.badge.plus")
                }
                .accessibilityLabel("Add character to scene")
                Button(role: .destructive, action: { showingDeleteConfirm = true }) {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Scene", isPresented: $showingDeleteConfirm, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteScene() }
        }, message: {
            Text("This will permanently delete the scene and its prompts.")
        })
        .sheet(isPresented: $showingCharacterList, onDismiss: charactersPickerDismissed) {
            StoryCharacterListView(story: story)
                .environment(\.managedObjectContext, ctx)
        }
    }

    // MARK: Chat Bar
    private var chatBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TextField("Type…", text: $newMessageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addMessage) {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 24))
                }
                .disabled(newMessageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private func deleteScene() {
        ctx.delete(scene)
        try? ctx.save()
        dismiss()
    }

    private func charactersPickerDismissed() {
        let current = Set(story.characters as? Set<Character> ?? [])
        let newChars = current.subtracting(prePickerCharacters)
        guard !newChars.isEmpty else { return }
        for char in newChars {
            insertSystemPrompt(text: "\(char.name ?? "Character") enters the scene.")
        }
    }

    private func removeCharacter(_ char: Character) {
        guard let set = story.characters as? Set<Character>, set.contains(char) else { return }
        let mutable = NSMutableSet(set: set)
        mutable.remove(char)
        story.characters = mutable
        try? ctx.save()
    }

    private func insertSystemPrompt(text: String) {
        let prompt = StoryPrompt(context: ctx)
        prompt.id = UUID(); prompt.createdAt = Date()
        prompt.promptText = text
        prompt.scene = scene; prompt.story = story
    }

    private func addMessage() {
        guard !newMessageText.isEmpty else { return }
        // Create a StoryPrompt attached to scene
        let prompt = StoryPrompt(context: ctx)
        prompt.id = UUID()
        prompt.promptText = newMessageText
        prompt.createdAt = Date()
        prompt.scene = scene
        try? ctx.save()
        newMessageText = ""
    }
}

#Preview {
    let ctx = PersistenceController.preview.container.viewContext
    let story = Story(context: ctx); story.title = "Preview"
    let sc = Scene(context: ctx); sc.title = "First Scene"; sc.summary = "Summary"; sc.createdAt = Date(); sc.story = story
    return NavigationView {
        SceneDetailView(scene: sc, story: story)
            .environment(\.managedObjectContext, ctx)
    }
}