import SwiftUI
import CoreData

struct SceneEditorView: View {
    enum Mode: Equatable { case new, edit(Scene) }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var ctx

    @StateObject private var viewModel: SceneViewModel
    private let mode: Mode

    @State private var title: String = ""
    @State private var summary: String = ""

    init(mode: Mode, viewModel: SceneViewModel) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: viewModel)
        if case .edit(let scene) = mode {
            _title = State(initialValue: scene.title ?? "")
            _summary = State(initialValue: scene.summary ?? "")
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $summary)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(modeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var modeTitle: String { mode == .new ? "New Scene" : "Edit Scene" }

    private func save() {
        switch mode {
        case .new:
            viewModel.addScene(title: title, summary: summary.isEmpty ? nil : summary)
        case .edit(let scene):
            viewModel.updateScene(scene, title: title, summary: summary.isEmpty ? nil : summary)
        }
        dismiss()
    }
}

// MARK: – Preview

#Preview {
    let ctx = PersistenceController.preview.container.viewContext
    let story = Story(context: ctx)
    story.id = UUID(); story.title = "Preview"
    let repo = SceneRepository(context: ctx)
    let vm = SceneViewModel(story: story, repository: repo)
    return SceneEditorView(mode: .new, viewModel: vm)
        .environment(\.managedObjectContext, ctx)
}