import SwiftUI
import CoreData

struct CharacterDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CharacterViewModel
    @State private var showingEditSheet = false
    let character: Character
    
    init(character: Character) {
        self.character = character
        _viewModel = StateObject(wrappedValue: CharacterViewModel(context: character.managedObjectContext!))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Avatar Section
                if let avatarURL = character.avatarURL {
                    AsyncImage(url: URL(string: avatarURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                        .frame(width: 150, height: 150)
                }
                
                // Character Info Section
                VStack(alignment: .leading, spacing: 16) {
                    Text(character.name ?? "Unnamed Character")
                        .font(.title)
                        .bold()
                    
                    if let description = character.characterDescription, !description.isEmpty {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(description)
                            .font(.body)
                    }
                    
                    // Stories Section
                    StoriesSection(character: character, viewModel: viewModel)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Character", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            CharacterEditorView(viewModel: viewModel, character: character)
        }
    }
}

// Extracted Stories Section to a separate view
struct StoriesSection: View {
    let character: Character
    let viewModel: CharacterViewModel
    
    var body: some View {
        Group {
            if let storiesSet = character.stories as? Set<Story>, !storiesSet.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Appears in Stories")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    ForEach(Array(storiesSet), id: \.self) { story in
                        StoryRow(story: story, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

// Extracted Story Row to a separate view
struct StoryRow: View {
    let story: Story
    let viewModel: CharacterViewModel
    
    var body: some View {
        NavigationLink(destination: StoryDetailView(story: story, viewModel: StoryViewModel(
            repository: StoryRepository(context: story.managedObjectContext!),
            openAIService: OpenAIService(apiKey: ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "")
        ))) {
            HStack {
                Text(story.title ?? "Untitled Story")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

struct CharacterDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let character = Character(context: context)
        character.name = "Preview Character"
        character.characterDescription = "This is a preview character description."
        return NavigationView {
            CharacterDetailView(character: character)
        }
    }
} 