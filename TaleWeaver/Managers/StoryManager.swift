import Foundation
import CoreData

/// Manages Story CRUD operations using an underlying repository.
class StoryManager {
    private let repository: StoryRepositoryProtocol
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        self.repository = StoryRepository(context: context)
    }

    func createStory(title: String, content: String, prompt: String) -> Story {
        do {
            return try repository.createStory(title: title, content: content, prompt: prompt)
        } catch {
            print("Error creating story: \(error)")
            let story = Story(context: context)
            story.title = title
            story.content = content
            return story
        }
    }

    func fetchStories() -> [Story] {
        do {
            return try repository.fetchStories()
        } catch {
            print("Error fetching stories: \(error)")
            return []
        }
    }

    func updateStory(_ story: Story, title: String, content: String) {
        do {
            try repository.updateStory(story, title: title, content: content)
        } catch {
            print("Error updating story: \(error)")
        }
    }

    func deleteStory(_ story: Story) {
        do {
            try repository.deleteStory(story)
        } catch {
            print("Error deleting story: \(error)")
        }
    }

    func addPrompt(to story: Story, text: String) {
        do {
            try repository.addPrompt(to: story, text: text)
        } catch {
            print("Error adding prompt: \(error)")
        }
    }
}
