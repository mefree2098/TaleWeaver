import SwiftUI
import CoreData

/// Shows a story’s scenes (no chat UI at this level).
struct StoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var story: Story
    @ObservedObject var viewModel: StoryViewModel

    @State private var showingEditSheet = false
    @State private var showingSceneList = false

    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            if story.scenesArray.isEmpty {
                // ----- Placeholder when the story has no scenes -----
                VStack {
                    Text(story.title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    Text("No scenes yet")
                        .foregroundColor(.secondary)
                    Button {
                        showingSceneList = true
                    } label: {
                        Label("Create Scene", systemImage: "plus")
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .padding()
            } else {
                // ----- List of scenes -----
                List {
                    Section(header: Text(story.title ?? "").font(.title2)) { }
                    ForEach(story.scenesArray, id: \.objectID) { scene in
                        NavigationLink(destination: SceneDetailView(scene: scene, story: story)) {
                            VStack(alignment: .leading) {
                                Text(scene.title ?? "Untitled")
                                    .font(.headline)
                                if let sum = scene.summary, !sum.isEmpty {
                                    Text(sum)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { showingSceneList = true } label: {
                    Image(systemName: "list.bullet.rectangle")
                }
                .accessibilityLabel("Manage scenes")

                Button { showingEditSheet = true } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit story")

                Button(role: .destructive) { showingDeleteAlert = true } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel("Delete story")
            }
        }
        .alert("Delete Story", isPresented: $showingDeleteAlert, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { deleteStory() }
        }, message: {
            Text("This will permanently delete the story and all related scenes.")
        })
        .sheet(isPresented: $showingEditSheet) {
            StoryEditorView(mode: .edit(story), viewModel: viewModel)
        }
        .sheet(isPresented: $showingSceneList) {
            NavigationStack {
                SceneListView(story: story)
                    .environment(\.managedObjectContext,
                                  story.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
        }
    }

    // MARK: Delete Story
    private func deleteStory() {
        let ctx = story.managedObjectContext ?? PersistenceController.shared.container.viewContext
        ctx.delete(story)
        try? ctx.save()
        dismiss()
    }
}


// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    let story = Story(context: context)
    story.title = "Sample Story"
    story.content = "This is a sample story content."
    return NavigationStack {
        StoryDetailView(story: story, viewModel: StoryViewModel(repository: StoryRepository(context: context), openAIService: OpenAIService(apiKey: "preview")))
            .environment(\.managedObjectContext, context)
    }
}