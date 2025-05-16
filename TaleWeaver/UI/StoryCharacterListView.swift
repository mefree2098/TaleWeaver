//
// StoryCharacterListView.swift
// TaleWeaver
//

import SwiftUI
import CoreData

struct StoryCharacterListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let story: Story

    @State private var searchText: String = ""
    @State private var selectedCharacter: Character?
    @State private var showingCharacterEditor: Bool = false
    @State private var showingDeleteConfirmation: Bool = false

    // Fetch all user-created characters
    @FetchRequest private var userCharacters: FetchedResults<Character>
    // Fetch all story-specific (non-user) characters
    @FetchRequest private var storyCharacters: FetchedResults<Character>

    init(story: Story) {
        self.story = story

        // User characters fetch request
        let userRequest: NSFetchRequest<Character> = Character.fetchRequest()
        userRequest.predicate = NSPredicate(format: "isUserCharacter == YES")
        userRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Character.name, ascending: true)
        ]
        _userCharacters = FetchRequest(fetchRequest: userRequest)

        // Story characters fetch request
        let storyRequest: NSFetchRequest<Character> = Character.fetchRequest()
        storyRequest.predicate = NSPredicate(format: "isUserCharacter == NO AND ANY stories == %@", story)
        storyRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Character.name, ascending: true)
        ]
        _storyCharacters = FetchRequest(fetchRequest: storyRequest)
    }

    // MARK: Filtered Lists

    private var filteredUserCharacters: [Character] {
        let list = Array(userCharacters)
        guard !searchText.isEmpty else { return list }
        return list.filter { character in
            let nameMatch = character.name?.localizedCaseInsensitiveContains(searchText) ?? false
            let descMatch = character.characterDescription?.localizedCaseInsensitiveContains(searchText) ?? false
            return nameMatch || descMatch
        }
    }

    private var filteredStoryCharacters: [Character] {
        let list = Array(storyCharacters)
        guard !searchText.isEmpty else { return list }
        return list.filter { character in
            let nameMatch = character.name?.localizedCaseInsensitiveContains(searchText) ?? false
            let descMatch = character.characterDescription?.localizedCaseInsensitiveContains(searchText) ?? false
            return nameMatch || descMatch
        }
    }

    // MARK: Body

    var body: some View {
        NavigationView {
            List {
                // User Characters Section
                Section(header: Text("User Characters")) {
                    ForEach(filteredUserCharacters, id: \.objectID) { char in
                        UserCharacterRow(
                            character: char,
                            story: story,
                            assignAction: assignCharacter(_:),
                            removeAction: removeCharacter(_:)
                        )
                    }
                    .onDelete(perform: deleteUserCharacters)
                }

                // Story Characters Section
                Section(header: Text("Story Characters")) {
                    ForEach(filteredStoryCharacters, id: \.objectID) { char in
                        StoryCharacterRow(
                            character: char,
                            editAction: { editCharacter(char) }
                        )
                    }
                    .onDelete(perform: deleteStoryCharacters)
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search characters")
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNewCharacter) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCharacterEditor) {
                StoryCharacterEditorViewNew(
                    character: selectedCharacter,
                    story: story
                )
                .environment(\.managedObjectContext, viewContext)
            }
            .alert("Delete Character", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    selectedCharacter = nil
                }
                Button("Delete", role: .destructive) {
                    deleteSelectedCharacter()
                }
            } message: {
                Text("This will remove the character and unassign it from the story.")
            }
        }
    }

    // MARK: Actions

    private func assignCharacter(_ character: Character) {
        let mutable = character.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        mutable.add(story)
        character.stories = mutable
        try? viewContext.save()
    }

    private func removeCharacter(_ character: Character) {
        let mutable = character.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        mutable.remove(story)
        character.stories = mutable
        try? viewContext.save()
    }

    private func deleteUserCharacters(at offsets: IndexSet) {
        for idx in offsets {
            let char = filteredUserCharacters[idx]
            viewContext.delete(char)
        }
        try? viewContext.save()
        // Haptic feedback on deletion
        FeedbackManager.shared.playNotificationFeedback(type: .warning)
    }

    private func deleteStoryCharacters(at offsets: IndexSet) {
        for idx in offsets {
            let char = filteredStoryCharacters[idx]
            let mutable = char.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
            mutable.remove(story)
            char.stories = mutable
            viewContext.delete(char)
        }
        try? viewContext.save()
        // Haptic feedback on deletion
        FeedbackManager.shared.playNotificationFeedback(type: .warning)
    }

    private func addNewCharacter() {
        selectedCharacter = nil
        showingCharacterEditor = true
    }

    private func editCharacter(_ character: Character) {
        selectedCharacter = character
        showingCharacterEditor = true
    }

    private func deleteSelectedCharacter() {
        guard let char = selectedCharacter else { return }
        let mutable = char.stories?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        mutable.remove(story)
        char.stories = mutable
        viewContext.delete(char)
        try? viewContext.save()
        selectedCharacter = nil
        // Haptic feedback on deletion
        FeedbackManager.shared.playNotificationFeedback(type: .warning)
    }
}

// MARK: – Row Views

struct UserCharacterRow: View {
    let character: Character
    let story: Story
    let assignAction: (Character) -> Void
    let removeAction: (Character) -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URLUtils.createURL(from: character.avatarURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(width: 50, height: 50)
                case .success(let img):
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(character.name ?? "")
                Text(character.characterDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if story.characters?.contains(character) == true {
                Button("Remove") { removeAction(character) }
                    .foregroundColor(.red)
            } else {
                Button("Assign") { assignAction(character) }
                    .foregroundColor(.blue)
            }
        }
    }
}

struct StoryCharacterRow: View {
    let character: Character
    let editAction: () -> Void

    var body: some View {
        HStack {
            AsyncImage(url: URLUtils.createURL(from: character.avatarURL ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView().frame(width: 50, height: 50)
                case .success(let img):
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(character.name ?? "")
                Text(character.characterDescription ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Edit", action: editAction)
                .foregroundColor(.blue)
        }
    }
}

// MARK: – Preview

struct StoryCharacterListView_Previews: PreviewProvider {
    static var previews: some View {
        let ctx = PersistenceController.preview.container.viewContext
        let previewStory = Story(context: ctx)
        previewStory.id = UUID()
        previewStory.title = "Preview Story"

        return StoryCharacterListView(story: previewStory)
            .environment(\.managedObjectContext, ctx)
    }
}
