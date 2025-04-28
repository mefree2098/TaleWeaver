import XCTest
import CoreData
@testable import TaleWeaver

class StoryManagerTests: XCTestCase {
    var storyManager: StoryManager!
    var container: NSPersistentContainer!
    
    override func setUp() {
        super.setUp()
        
        // Create an in-memory persistent container for testing
        container = NSPersistentContainer(name: "TaleWeaver")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            XCTAssertNil(error, "Failed to load persistent stores: \(error?.localizedDescription ?? "")")
        }
        
        storyManager = StoryManager(context: container.viewContext)
    }
    
    override func tearDown() {
        storyManager = nil
        container = nil
        super.tearDown()
    }
    
    func testCreateStory() {
        // Create a test story
        let title = "Test Story"
        let content = "Once upon a time..."
        let prompt = "Write a story about a magical forest"
        
        let story = storyManager.createStory(title: title, content: content, prompt: prompt)
        
        XCTAssertNotNil(story, "Story should not be nil")
        XCTAssertEqual(story.title, title, "Story title should match")
        XCTAssertEqual(story.content, content, "Story content should match")
        XCTAssertEqual(story.prompts?.count, 1, "Story should have one prompt")
        
        if let firstPrompt = story.prompts?.first as? StoryPrompt {
            XCTAssertEqual(firstPrompt.text, prompt, "Prompt text should match")
        } else {
            XCTFail("Story should have a prompt")
        }
    }
    
    func testFetchStories() {
        // Create multiple stories
        let story1 = storyManager.createStory(title: "Story 1", content: "Content 1", prompt: "Prompt 1")
        let story2 = storyManager.createStory(title: "Story 2", content: "Content 2", prompt: "Prompt 2")
        
        // Save context
        try? container.viewContext.save()
        
        // Fetch stories
        let stories = storyManager.fetchStories()
        
        XCTAssertEqual(stories.count, 2, "Should fetch 2 stories")
        XCTAssertTrue(stories.contains(story1), "Should contain story 1")
        XCTAssertTrue(stories.contains(story2), "Should contain story 2")
    }
    
    func testDeleteStory() {
        // Create a story
        let story = storyManager.createStory(title: "Test Story", content: "Content", prompt: "Prompt")
        try? container.viewContext.save()
        
        // Delete the story
        storyManager.deleteStory(story)
        try? container.viewContext.save()
        
        // Verify story is deleted
        let stories = storyManager.fetchStories()
        XCTAssertFalse(stories.contains(story), "Story should be deleted")
    }
    
    func testUpdateStory() {
        // Create a story
        let story = storyManager.createStory(title: "Original Title", content: "Original Content", prompt: "Original Prompt")
        try? container.viewContext.save()
        
        // Update the story
        let newTitle = "Updated Title"
        let newContent = "Updated Content"
        storyManager.updateStory(story, title: newTitle, content: newContent)
        try? container.viewContext.save()
        
        // Verify updates
        XCTAssertEqual(story.title, newTitle, "Title should be updated")
        XCTAssertEqual(story.content, newContent, "Content should be updated")
    }
    
    func testAddPrompt() {
        // Create a story
        let story = storyManager.createStory(title: "Test Story", content: "Content", prompt: "Initial Prompt")
        
        // Add a new prompt
        let newPrompt = "Additional Prompt"
        storyManager.addPrompt(to: story, text: newPrompt)
        try? container.viewContext.save()
        
        // Verify prompt was added
        XCTAssertEqual(story.prompts?.count, 2, "Story should have two prompts")
        
        let prompts = story.prompts?.allObjects as? [StoryPrompt]
        XCTAssertTrue(prompts?.contains { $0.text == newPrompt } ?? false, "Should contain the new prompt")
    }
} 