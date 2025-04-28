import SwiftUI
import CoreData

struct StoryDetailView: View {
    let story: Story
    @ObservedObject var viewModel: StoryViewModel
    @State private var showingEditSheet = false
    @State private var showingNewPromptSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(story.title ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                Text(story.content ?? "")
                    .font(.body)
                    .lineSpacing(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Prompts")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    ForEach(story.promptsArray) { prompt in
                        PromptView(prompt: prompt)
                    }
                    
                    Button(action: { showingNewPromptSheet = true }) {
                        Label("Add Prompt", systemImage: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add new prompt")
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel("Edit story")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            StoryEditorView(mode: .edit(story), viewModel: viewModel)
        }
        .sheet(isPresented: $showingNewPromptSheet) {
            NewPromptView(story: story, viewModel: viewModel)
        }
    }
}

struct PromptView: View {
    let prompt: StoryPrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prompt.promptText ?? "")
                .font(.subheadline)
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(prompt.createdAt ?? Date(), style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prompt: \(prompt.promptText ?? "")")
    }
}

struct NewPromptView: View {
    let story: Story
    @ObservedObject var viewModel: StoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var promptText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextEditor(text: $promptText)
                        .frame(height: 100)
                } header: {
                    Text("Enter your prompt")
                }
            }
            .navigationTitle("New Prompt")
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
                        viewModel.addPrompt(to: story, text: promptText)
                        dismiss()
                    }
                    .disabled(promptText.isEmpty)
                    .accessibilityLabel("Add prompt")
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
    
    return StoryDetailView(story: story, viewModel: StoryViewModel(repository: StoryRepository(context: context), openAIService: OpenAIService(apiKey: "preview-key")))
        .environment(\.managedObjectContext, context)
} 