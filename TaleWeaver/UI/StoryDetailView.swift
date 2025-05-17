import SwiftUI
import CoreData

struct StoryDetailView: View {
    let story: Story
    @ObservedObject var viewModel: StoryViewModel
    @State private var showingEditSheet = false
    @State private var showingNewPromptSheet = false
    @State private var newMessageText: String = ""
    @State private var isAddingMessage: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Story content section
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
                    
                    // Chat transcript section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Conversation")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)
                        
                        ForEach(story.promptsArray) { prompt in
                            ChatMessageView(prompt: prompt, userCharacter: story.userCharacter)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: story.promptsArray.count)
                }
                .padding()
            }
            
            // Chat input section
            VStack(spacing: 0) {
                Divider()
                HStack {
                    TextField("Type a message...", text: $newMessageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                    
                    Button(action: addMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(newMessageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(newMessageText.isEmpty || isAddingMessage)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: -1)
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
    }
    
    private func addMessage() {
        guard !newMessageText.isEmpty else { return }
        
        isAddingMessage = true
        
        Task {
            viewModel.addPrompt(to: story, text: newMessageText)
            await MainActor.run {
                newMessageText = ""
                isAddingMessage = false
            }
        }
    }
}

struct ChatMessageView: View {
    let prompt: StoryPrompt
    let userCharacter: Character?
    
    var body: some View {
        HStack(alignment: .top) {
            // Avatar or placeholder
            if let userCharacter = userCharacter, let avatarURL = userCharacter.avatarURL, !avatarURL.isEmpty {
                AsyncImage(url: URL(string: avatarURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String((userCharacter.name?.prefix(1) ?? "U")))
                                .font(.headline)
                                .foregroundColor(.gray)
                        )
                }
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("U")
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Character name
                Text(userCharacter?.name ?? "User")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                // Message content
                Text(prompt.promptText ?? "")
                    .font(.body)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                
                // Timestamp
                Text(prompt.createdAt ?? Date(), style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Message from \(userCharacter?.name ?? "User"): \(prompt.promptText ?? "")")
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let story = Story(context: context)
    story.title = "Sample Story"
    story.content = "This is a sample story content."
    
    // Create a user character
    let character = Character(context: context)
    character.name = "John"
    character.characterDescription = "A brave adventurer"
    character.isUserCharacter = true
    story.userCharacter = character
    
    // Create some prompts
    let prompt1 = StoryPrompt(context: context)
    prompt1.promptText = "Hello, this is a test message."
    prompt1.createdAt = Date().addingTimeInterval(-3600)
    prompt1.story = story
    
    let prompt2 = StoryPrompt(context: context)
    prompt2.promptText = "Another message in the conversation."
    prompt2.createdAt = Date().addingTimeInterval(-1800)
    prompt2.story = story
    
    return StoryDetailView(story: story, viewModel: StoryViewModel(repository: StoryRepository(context: context), openAIService: OpenAIService(apiKey: "preview-key")))
        .environment(\.managedObjectContext, context)
} 