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
    @State private var isGenerating = false

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
                    ZStack(alignment: .topTrailing) {
                        TextEditor(text: $summary)
                            .frame(minHeight: 160)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                        if isGenerating {
                            ProgressView()
                                .padding()
                        }
                    }
                    HStack {
                        Button("AI: Generate") { generateDescription() }
                        Button("AI: Improve") { improveDescription() }
                    }
                    .disabled(isGenerating || (summary.isEmpty && !title.isEmpty))
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

    private var improveDisabled: Bool { summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private func generateDescription() {
        isGenerating = true
        Task {
            let base = title.isEmpty ? "a scene" : title
            if let txt = await viewModel.generateDescription(for: base) {
                await MainActor.run { summary = txt }
            }
            isGenerating = false
        }
    }

    private func improveDescription() {
        isGenerating = true
        Task {
            if let txt = await viewModel.generateDescription(for: summary) {
                await MainActor.run { summary = txt }
            }
            isGenerating = false
        }
    }

    private func save() {
        switch mode {
        case .new:
            viewModel.addScene(title: title, summary: summary.isEmpty ? nil : summary)
        case .edit(let scene):
            viewModel.updateScene(scene, title: title, summary: summary.isEmpty ? nil : summary)
        }
        viewModel.refresh()
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