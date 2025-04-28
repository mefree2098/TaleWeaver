import Foundation
import CoreData

enum RepositoryError: Error {
    case fetchError(Error)
    case saveError(Error)
    case deleteError(Error)
}

protocol StoryRepositoryProtocol {
    func fetchStories() throws -> [Story]
    func createStory(title: String, content: String, prompt: String) throws -> Story
    func updateStory(_ story: Story, title: String, content: String) throws
    func deleteStory(_ story: Story) throws
    func addPrompt(to story: Story, text: String) throws
}

class StoryRepository: StoryRepositoryProtocol {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchStories() throws -> [Story] {
        let request: NSFetchRequest<Story> = Story.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Story.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            throw RepositoryError.fetchError(error)
        }
    }
    
    func createStory(title: String, content: String, prompt: String) throws -> Story {
        let story = Story(context: context)
        story.id = UUID()
        story.title = title
        story.content = content
        story.createdAt = Date()
        story.updatedAt = Date()
        
        let storyPrompt = StoryPrompt(context: context)
        storyPrompt.id = UUID()
        storyPrompt.promptText = prompt
        storyPrompt.createdAt = Date()
        storyPrompt.story = story
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveError(error)
        }
        
        return story
    }
    
    func updateStory(_ story: Story, title: String, content: String) throws {
        story.title = title
        story.content = content
        story.updatedAt = Date()
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveError(error)
        }
    }
    
    func deleteStory(_ story: Story) throws {
        context.delete(story)
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.deleteError(error)
        }
    }
    
    func addPrompt(to story: Story, text: String) throws {
        let storyPrompt = StoryPrompt(context: context)
        storyPrompt.id = UUID()
        storyPrompt.promptText = text
        storyPrompt.createdAt = Date()
        storyPrompt.story = story
        
        do {
            try context.save()
        } catch {
            throw RepositoryError.saveError(error)
        }
    }
} 