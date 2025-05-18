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
    @State private var selectedCharacters: Set<Character> = []

    init(mode: Mode, viewModel: SceneViewModel) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: viewModel)
        if case .edit(let scene) = mode {
            _title = State(initialValue: scene.title ?? "")
            _summary = State(initialValue: scene.summary ?? "")
            _selectedCharacters = State(initialValue: Set(scene.story?.characters as? Set<Character> ?? []))
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

                Section(header: Text("Characters in Scene")) {
                    ForEach(allCharacters, id: \.objectID) { char in
                        MultipleSelectionRow(title: char.name ?? "", isSelected: selectedCharacters.contains(char)) {
                            toggleSelection(char)
                        }
                    }
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

    // MARK: Character helpers
    private var allCharacters: [Character] {
        let set = viewModel.story.characters as? Set<Character> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    private func toggleSelection(_ char: Character) {
        if selectedCharacters.contains(char) {
            selectedCharacters.remove(char)
        } else {
            selectedCharacters.insert(char)
        }
    }

    // MARK: AI
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
        let originalChars = Set(viewModel.story.characters as? Set<Character> ?? [])
        let newChars = selectedCharacters.subtracting(originalChars)

        switch mode {
        case .new:
            let scene = viewModel.addScene(title: title, summary: summary.isEmpty ? nil : summary)
            attachCharacters(newChars, to: scene)
        case .edit(let scene):
            viewModel.updateScene(scene, title: title, summary: summary.isEmpty ? nil : summary)
            attachCharacters(newChars, to: scene)
        }
        viewModel.refresh()
        dismiss()
    }

    private func attachCharacters(_ chars: Set<Character>, to scene: Scene) {
        guard !chars.isEmpty else { return }
        for char in chars {
            insertSystemPrompt(text: "\(char.name ?? "Character") enters the scene.", into: scene)
        }
        try? ctx.save()
    }

    private func insertSystemPrompt(text: String, into scene: Scene) {
        let prompt = StoryPrompt(context: ctx)
        prompt.id = UUID(); prompt.createdAt = Date(); prompt.promptText = text
        prompt.scene = scene; prompt.story = viewModel.story
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