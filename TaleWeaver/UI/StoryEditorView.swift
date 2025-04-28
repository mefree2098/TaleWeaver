import SwiftUI
import CoreData

enum StoryEditorMode: Equatable {
    case new
    case edit(Story)
}

struct StoryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: StoryViewModel
    
    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var content: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showingError: Bool = false
    
    private let mode: StoryEditorMode
    
    init(mode: StoryEditorMode, viewModel: StoryViewModel? = nil) {
        self.mode = mode
        
        if let viewModel = viewModel {
            // Use the provided view model
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            // Create repository and service
            let repository = StoryRepository(context: PersistenceController.shared.container.viewContext)
            let openAIService = OpenAIService(apiKey: Configuration.openAIAPIKey)
            
            // Initialize view model with dependencies
            _viewModel = StateObject(wrappedValue: StoryViewModel(repository: repository, openAIService: openAIService))
        }
        
        // Initialize state based on mode
        if case .edit(let story) = mode {
            _title = State(initialValue: story.title ?? "")
            if let firstPrompt = story.promptsArray.first {
                _prompt = State(initialValue: firstPrompt.promptText ?? "")
            }
            _content = State(initialValue: story.content ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Story Details")) {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Story title")
                    
                    TextField("Prompt", text: $prompt)
                        .accessibilityLabel("Story prompt")
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .accessibilityLabel("Story content")
                }
                
                if isGenerating {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .accessibilityLabel("Generating story")
                            Spacer()
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .accessibilityLabel("Error message")
                    }
                }
            }
            .navigationTitle(mode == .new ? "New Story" : "Edit Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel editing")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(mode == .new ? "Create" : "Save") {
                        saveStory()
                    }
                    .disabled(title.isEmpty || prompt.isEmpty)
                    .accessibilityLabel(mode == .new ? "Create story" : "Save story")
                }
            }
        }
    }
    
    private func saveStory() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            switch mode {
            case .new:
                await viewModel.createStory(title: title, prompt: prompt)
                await MainActor.run {
                    if let error = viewModel.error {
                        errorMessage = error.localizedDescription
                        showingError = true
                    } else {
                        dismiss()
                    }
                    isGenerating = false
                }
            case .edit(let story):
                viewModel.updateStory(story, title: title, content: content)
                await MainActor.run {
                    dismiss()
                    isGenerating = false
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let story = Story(context: context)
    story.title = "Sample Story"
    story.content = "This is a sample story content."
    
    let repository = StoryRepository(context: context)
    let openAIService = OpenAIService(apiKey: "preview-key")
    let viewModel = StoryViewModel(repository: repository, openAIService: openAIService)
    
    return StoryEditorView(mode: .edit(story), viewModel: viewModel)
        .environment(\.managedObjectContext, context)
} 
