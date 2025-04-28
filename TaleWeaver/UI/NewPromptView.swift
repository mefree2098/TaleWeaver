import SwiftUI
import CoreData

struct NewPromptView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: StoryViewModel
    let story: Story
    
    @State private var promptText: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    
    init(viewModel: StoryViewModel, story: Story) {
        self.viewModel = viewModel
        self.story = story
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Prompt")) {
                    TextEditor(text: $promptText)
                        .frame(height: 150)
                        .accessibilityLabel("Prompt text")
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
            .navigationTitle("Add Prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel adding prompt")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addPrompt()
                    }
                    .disabled(promptText.isEmpty)
                    .accessibilityLabel("Add prompt")
                }
            }
        }
    }
    
    private func addPrompt() {
        isGenerating = true
        errorMessage = nil
        
        Task {
            viewModel.addPrompt(to: story, text: promptText)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

struct NewPromptView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let story = Story(context: context)
        story.title = "Sample Story"
        
        let repository = StoryRepository(context: context)
        let openAIService = OpenAIService(apiKey: "preview-key")
        let viewModel = StoryViewModel(repository: repository, openAIService: openAIService)
        
        return NewPromptView(viewModel: viewModel, story: story)
            .environment(\.managedObjectContext, context)
    }
} 