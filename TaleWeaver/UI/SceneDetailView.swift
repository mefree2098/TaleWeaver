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

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(scene.title ?? "Untitled")
                        .font(.title)
                    if let sum = scene.summary {
                        Text(sum).font(.body)
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCharacterList = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingCharacterList) {
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