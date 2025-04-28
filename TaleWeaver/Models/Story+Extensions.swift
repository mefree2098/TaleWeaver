import Foundation
import CoreData

extension Story {
    var promptsArray: [StoryPrompt] {
        let set = prompts as? Set<StoryPrompt> ?? []
        return set.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
    }
} 