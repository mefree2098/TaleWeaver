import SwiftUI
import CoreData

struct StoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Story.createdAt, ascending: false)],
        animation: .default)
    private var stories: FetchedResults<Story>
    
    @State private var showingNewStory = false
    @State private var showingSettings = false
    @State private var searchText = ""
    
    // Use the view model passed from the parent
    @ObservedObject var viewModel: StoryViewModel
    
    var body: some View {
        NavigationView {
            mainContent
        }
    }
    
    // Break up the complex view into smaller components
    private var mainContent: some View {
        ZStack {
            backgroundGradient
            
            if stories.isEmpty {
                emptyStateView
            } else {
                storyList
            }
        }
        .navigationTitle("TaleWeaver")
        .searchable(text: $searchText, prompt: "Search stories")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                newStoryButton
            }
        }
        .sheet(isPresented: $showingNewStory) {
            StoryEditorView(mode: .new, viewModel: viewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No stories yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Tap the + button to create your first story")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var storyList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredStories) { story in
                    storyCardLink(for: story)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteStory(story)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    private func storyCardLink(for story: Story) -> some View {
        NavigationLink(destination: StoryDetailView(story: story, viewModel: viewModel)) {
            StoryCardView(story: story)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var newStoryButton: some View {
        Button(action: { showingNewStory = true }) {
            Label("New Story", systemImage: "plus")
        }
    }
    
    private var filteredStories: [Story] {
        if searchText.isEmpty {
            return Array(stories)
        } else {
            return stories.filter { story in
                (story.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (story.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    private func deleteStory(_ story: Story) {
        withAnimation {
            viewContext.delete(story)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting story: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct StoryCardView: View {
    let story: Story
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            storyHeader
            
            storyFooter
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private var storyHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(story.content?.prefix(100) ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
    }
    
    private var storyFooter: some View {
        HStack {
            Text(story.createdAt ?? Date(), style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(story.promptsArray.count) prompts")
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        let repository = StoryRepository(context: PersistenceController.preview.container.viewContext)
        let openAIService = OpenAIService(apiKey: Configuration.openAIAPIKey)
        let viewModel = StoryViewModel(repository: repository, openAIService: openAIService)
        
        return StoryListView(viewModel: viewModel)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 