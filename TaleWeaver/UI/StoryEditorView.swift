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
        
        // Initialize template view model
        _templateViewModel = StateObject(wrappedValue: TemplateViewModel(context: PersistenceController.shared.container.viewContext))
        
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
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
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
            }
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView(viewModel: templateViewModel) { template in
                    selectedTemplate = template
                    let generatedPrompt = templateViewModel.generatePrompt(from: template)
                    prompt = generatedPrompt
                }
            }
            .sheet(isPresented: $showingCharacterEditor) {
                if case .edit(let story) = mode {
                    StoryCharacterEditorViewNew(character: selectedCharacter, story: story)
                }
            }
            .sheet(isPresented: $showingCharacterList) {
                if case .edit(let story) = mode {
                    StoryCharacterListView(story: story)
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
                        AsyncImage(url: URL(string: avatarURL)) { image in
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
        guard !name.isEmpty else { return }
        
        isGeneratingAvatar = true
        errorMessage = nil
        
        Task {
            do {
                let description = "A character named \(name). \(self.description)"
                let url = try await viewModel.generateCharacterAvatar(name: description)
                
                await MainActor.run {
                    avatarURL = url
                    isGeneratingAvatar = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isGeneratingAvatar = false
                }
            }
        }
    }
}

struct StoryCharacterListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showingCharacterEditor = false
    @State private var selectedCharacter: Character?
    let story: Story
    
    var filteredCharacters: [Character] {
        if searchText.isEmpty {
            return Array(story.characters as? Set<Character> ?? [])
        } else {
            return Array(story.characters as? Set<Character> ?? []).filter { character in
                character.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var userCharacters: [Character] {
        let fetchRequest: NSFetchRequest<Character> = Character.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isUserCharacter == YES")
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("User Character")) {
                    if let userCharacter = story.userCharacter {
                        HStack {
                            Text(userCharacter.name ?? "")
                            Spacer()
                            Button("Remove") {
                                story.userCharacter = nil
                                try? viewContext.save()
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        Text("No user character assigned")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Available User Characters")) {
                    ForEach(userCharacters, id: \.id) { character in
                        HStack {
                            Text(character.name ?? "")
                            Spacer()
                            if story.userCharacter == nil {
                                Button("Assign") {
                                    story.userCharacter = character
                                    try? viewContext.save()
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Story Characters")) {
                    ForEach(filteredCharacters, id: \.id) { character in
                        HStack {
                            Text(character.name ?? "")
                            Spacer()
                            Button("Edit") {
                                selectedCharacter = character
                                showingCharacterEditor = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .onDelete { indexSet in
                        let charactersToDelete = indexSet.map { filteredCharacters[$0] }
                        for character in charactersToDelete {
                            story.removeFromCharacters(character)
                        }
                        try? viewContext.save()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search characters")
            .navigationTitle("Characters")
            .navigationBarItems(
                leading: Button("Done") { dismiss() },
                trailing: Button("Add Character") {
                    selectedCharacter = nil
                    showingCharacterEditor = true
                }
            )
            .sheet(isPresented: $showingCharacterEditor) {
                StoryCharacterEditorViewNew(character: selectedCharacter, story: story)
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
