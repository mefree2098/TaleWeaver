import Foundation
import CoreData
import SwiftUI

@MainActor
class StoryViewModel: ObservableObject {
    private let repository: StoryRepositoryProtocol
    private let openAIService: OpenAIService
    
    @Published var stories: [Story] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(repository: StoryRepositoryProtocol, openAIService: OpenAIService) {
        self.repository = repository
        self.openAIService = openAIService
    }
    
    func loadStories() {
        do {
            stories = try repository.fetchStories()
        } catch {
            self.error = error
        }
    }
    
    func createStory(title: String, prompt: String) async {
        isLoading = true
        error = nil
        
        do {
            let generatedContent = try await openAIService.generateStory(prompt: prompt)
            let story = try repository.createStory(title: title, content: generatedContent, prompt: prompt)
            stories.insert(story, at: 0)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func updateStory(_ story: Story, title: String, content: String) {
        do {
            try repository.updateStory(story, title: title, content: content)
            if let index = stories.firstIndex(of: story) {
                stories[index] = story
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteStory(_ story: Story) {
        do {
            try repository.deleteStory(story)
            stories.removeAll { $0 == story }
        } catch {
            self.error = error
        }
    }
    
    func addPrompt(to story: Story, text: String) {
        do {
            try repository.addPrompt(to: story, text: text)
            if let index = stories.firstIndex(of: story) {
                stories[index] = story
            }
        } catch {
            self.error = error
        }
    }
} 