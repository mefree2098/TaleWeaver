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
    @StateObject private var templateViewModel: TemplateViewModel
    
    @State private var title: String = ""
    @State private var prompt: String = ""
    @State private var content: String = ""
    @State private var isGenerating: Bool = false
    @State private var errorMessage: String?
    @State private var showingError: Bool = false
    @State private var showingTemplateSelection: Bool = false
    @State private var selectedTemplate: StoryTemplate?
    @State private var showingCharacterEditor = false
    @State private var showingCharacterList = false
    @State private var selectedCharacter: Character?
    
    private let mode: StoryEditorMode
    
    init(mode: StoryEditorMode, viewModel: StoryViewModel) {
        self.mode = mode
        _viewModel = StateObject(wrappedValue: viewModel)
        _templateViewModel = StateObject(wrappedValue: TemplateViewModel(context: PersistenceController.shared.container.viewContext))
        
        if case .edit(let story) = mode {
            _title = State(initialValue: story.title ?? "")
            _content = State(initialValue: story.content ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Story Details")) {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Story title")
                    
                    if mode == .new {
                        Button(action: { showingTemplateSelection = true }) {
                            HStack {
                                Text(selectedTemplate?.name ?? "Select Template")
                                    .foregroundColor(selectedTemplate == nil ? .blue : .primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .accessibilityLabel("Select story template")
                    }
                    
                    if let template = selectedTemplate {
                        Text(template.templateDescription ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Template description")
                    }
                    
                    TextField("Prompt", text: $prompt)
                        .accessibilityLabel("Story prompt")
                }
                
                Section(header: Text("Content")) {
                    ZStack(alignment: .topTrailing) {
                        TextEditor(text: $content)
                            .frame(minHeight: 220)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
                        if isGenerating {
                            ProgressView().padding()
                        }
                    }
                    HStack {
                        Button("AI Generate Story") { generateStory() }
                        Button("AI Improve Story") { improveStory() }
                    }
                    .disabled(isGenerating || title.isEmpty)
                    .accessibilityLabel("Story content")
                }
                
                Section(header: Text("Characters")) {
                    Button(action: { showingCharacterList = true }) {
                        Label("Manage Story Characters", systemImage: "person.2")
                    }
                    .accessibilityLabel("Manage story characters")
                    
                    Button(action: { 
                        selectedCharacter = nil
                        showingCharacterEditor = true 
                    }) {
                        Label("Add New Character", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Add new story character")
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
                .disabled(title.isEmpty || prompt.isEmpty || (mode == .new && selectedTemplate == nil))
                        .accessibilityLabel(mode == .new ? "Create story" : "Save story")
                }
                // Removed invalid .onChange on ToolbarItem
                
                // end ToolbarItem(s)
            }
            // Haptic and visual feedback on save (attached to Form instead of ToolbarItem)
            .onReceive(NotificationCenter.default.publisher(for: .init("StorySaveSuccess"))) { _ in
                FeedbackManager.shared.playNotificationFeedback(type: .success)
            }
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView(viewModel: templateViewModel) { template in
                    selectedTemplate = template
                    let generatedPrompt = templateViewModel.generatePrompt(from: template, context: [:])
                    prompt = generatedPrompt
                }
            }
            .sheet(isPresented: $showingCharacterEditor, onDismiss: {
                selectedCharacter = nil
            }) {
                if case .edit(let story) = mode {
                    StoryCharacterEditorViewNew(character: selectedCharacter, story: story)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .sheet(isPresented: $showingCharacterList) {
                if case .edit(let story) = mode {
                    StoryCharacterListView(story: story)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    // MARK: – AI Helpers
    private func generateStory() {
        isGenerating = true
        Task {
            do {
                let txt = try await viewModel.openAIService.generateStory(prompt: prompt.isEmpty ? title : prompt)
                await MainActor.run { content = txt; isGenerating = false }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGenerating = false
                }
            }
        }
    }
    private func improveStory() {
        guard !content.isEmpty else { return }
        isGenerating = true
        Task {
            do {
                let txt = try await viewModel.openAIService.generateStory(prompt: "Improve the following story: \n\n" + content)
                await MainActor.run { content = txt; isGenerating = false }
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription; isGenerating = false }
            }
        }
    }

    private func saveStory() {
        if case .edit(let story) = mode {
            story.title = title
            story.content = content
            story.updatedAt = Date()
            
            if let error = errorMessage {
                print("Error saving story: \(error)")
                return
            }
            
            do {
                try viewContext.save()
                // Haptic feedback on save
                FeedbackManager.shared.playNotificationFeedback(type: .success)
                dismiss()
            } catch {
                print("Error saving story: \(error)")
                errorMessage = "Failed to save story: \(error.localizedDescription)"
            }
        } else {
            let story = Story(context: viewContext)
            story.id = UUID()
            story.title = title
            story.content = content
            story.createdAt = Date()
            story.updatedAt = Date()
            
            if let template = selectedTemplate {
                story.template = template
            }
            
            do {
                try viewContext.save()
                // Haptic feedback on save
                FeedbackManager.shared.playNotificationFeedback(type: .success)
                dismiss()
            } catch {
                print("Error saving story: \(error)")
                errorMessage = "Failed to save story: \(error.localizedDescription)"
            }
        }
    }
}

struct StoryCharacterEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CharacterViewModel
    let story: Story?
    let character: Character?
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var avatarURL: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isGeneratingAvatar = false
    @State private var errorMessage: String?
    
    init(viewModel: CharacterViewModel, story: Story?, character: Character? = nil) {
        self.viewModel = viewModel
        self.story = story
        self.character = character
        
        if let character = character {
            _name = State(initialValue: character.name ?? "")
            _description = State(initialValue: character.characterDescription ?? "")
            _avatarURL = State(initialValue: character.avatarURL ?? "")
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Character Details")) {
                    TextField("Name", text: $name)
                        .accessibilityLabel("Character name")
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .accessibilityLabel("Character description")
                }
                
                Section(header: Text("Avatar")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .accessibilityLabel("Selected character avatar")
                    } else if !avatarURL.isEmpty {
                        AsyncImage(url: URLUtils.createURL(from: avatarURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(height: 200)
                        .accessibilityLabel("Character avatar from URL")
                    }
                    
                    HStack {
                        Button(action: {
                            generateAvatar()
                        }) {
                            Label("Generate Avatar", systemImage: "wand.and.stars")
                        }
                        .disabled(name.isEmpty || isGeneratingAvatar)
                        .accessibilityLabel("Generate character avatar")
                    }
                    
                    if isGeneratingAvatar {
                        ProgressView()
                            .accessibilityLabel("Generating avatar")
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .accessibilityLabel("Error: \(error)")
                    }
                }
            }
            .navigationTitle(story == nil ? "New Story Character" : "Edit Story Character")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveCharacter()
                }
                .disabled(name.isEmpty)
            )
            .sheet(isPresented: $showingImagePicker) {
                CharacterImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveCharacter() {
        if let character = character {
            viewModel.updateCharacter(character, name: name, description: description, avatarURL: avatarURL)
        } else {
            let newCharacter = viewModel.createCharacter(name: name, description: description, avatarURL: avatarURL, isUserCharacter: false)
            
            if let story = story {
                let characters = story.characters?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
                characters.add(newCharacter)
                story.characters = characters
                try? story.managedObjectContext?.save()
            }
        }
        
        dismiss()
    }
    
    private func generateAvatar() {
        isGeneratingAvatar = true
        Task {
            do {
                let characterId = UUID().uuidString
                let url = try await viewModel.generateCharacterAvatar(
                    description: description,
                    characterId: characterId
                )
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                print("Error generating avatar: \(error)")
                isGeneratingAvatar = false
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
