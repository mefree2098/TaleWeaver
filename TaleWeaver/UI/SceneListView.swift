import SwiftUI
import CoreData

struct SceneListView: View {
    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: SceneViewModel
    @State private var showingEditor = false
    @State private var editorMode: SceneEditorView.Mode = .new
    @State private var selectedScene: Scene?

    private let parentStory: Story
    init(story: Story) {
        self.parentStory = story
        let repo = SceneRepository(context: story.managedObjectContext ?? PersistenceController.shared.container.viewContext)
        _viewModel = StateObject(wrappedValue: SceneViewModel(story: story, repository: repo))
    }

    var body: some View {
        List {
            if viewModel.scenes.isEmpty {
                VStack(alignment: .center) {
                    Text("No scenes yet")
                        .foregroundColor(.secondary)
                    Button(action: createScene) {
                        Label("Create Scene", systemImage: "plus")
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            ForEach(viewModel.scenes, id: \.objectID) { scene in
                NavigationLink(destination: SceneDetailView(scene: scene, story: parentStory)) {
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
                .swipeActions(edge: .trailing) {
                    Button("Edit") { openEditor(scene) }
                }
            }
            .onDelete(perform: deleteScenes)
        }
        .navigationTitle("Scenes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { createScene() }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            SceneEditorView(mode: editorMode, viewModel: viewModel)
                .environment(\.managedObjectContext, ctx)
        }
    }

    private func deleteScenes(at offsets: IndexSet) {
        offsets.map { viewModel.scenes[$0] }.forEach(viewModel.deleteScene)
    }

    private func createScene() {
        editorMode = .new
        showingEditor = true
    }

    private func openEditor(_ scene: Scene) {
        selectedScene = scene
        editorMode = .edit(scene)
        showingEditor = true
    }
}

#Preview {
    let ctx = PersistenceController.preview.container.viewContext
    let story = Story(context: ctx)
    story.id = UUID(); story.title = "Preview Story"
    return NavigationView {
        SceneListView(story: story)
            .environment(\.managedObjectContext, ctx)
    }
}