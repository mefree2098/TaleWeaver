import Foundation
import CoreData
import SwiftUI

class CharacterViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var characters: [Character] = []
    @Published var userCharacters: [Character] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let openAIService: OpenAIService
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.openAIService = OpenAIService(apiKey: Configuration.openAIAPIKey)
        fetchCharacters()
    }
    
    func fetchCharacters() {
        let request = NSFetchRequest<Character>(entityName: "Character")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Character.name, ascending: true)]
        
        do {
            characters = try context.fetch(request)
            userCharacters = characters.filter { $0.isUserCharacter }
        } catch {
            print("Error fetching characters: \(error)")
            characters = []
            userCharacters = []
        }
    }
    
    func createCharacter(name: String, description: String, avatarURL: String?, isUserCharacter: Bool = false) -> Character {
        let character = Character(context: context)
        character.id = UUID()
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        character.createdAt = Date()
        character.isUserCharacter = isUserCharacter
        
        saveContext()
        fetchCharacters()
        return character
    }
    
    func updateCharacter(_ character: Character, name: String, description: String, avatarURL: String?) {
        let oldName = character.name
        
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        character.updatedAt = Date()
        
        // Update character name in all associated stories
        if let stories = character.stories as? Set<Story> {
            for story in stories {
                updateCharacterNameInStory(story, oldName: oldName, newName: name)
            }
        }
        
        saveContext()
        fetchCharacters()
    }
    
    func deleteCharacter(_ character: Character) {
        context.delete(character)
        saveContext()
        fetchCharacters()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func generateCharacterAvatar(description: String, characterId: String, forceRegenerate: Bool = false) async throws -> String {
        return try await openAIService.generateCharacterAvatar(
            description: description,
            characterId: characterId,
            forceRegenerate: forceRegenerate
        )
    }
    
    private func updateCharacterNameInStory(_ story: Story, oldName: String?, newName: String) {
        guard let oldName = oldName, let content = story.content, !content.isEmpty else { return }
        
        // Replace character name in story content
        let updatedContent = content.replacingOccurrences(of: oldName, with: newName)
        story.content = updatedContent
        
        // Update character name in prompts
        if let prompts = story.prompts as? Set<StoryPrompt> {
            for prompt in prompts {
                if let promptText = prompt.promptText {
                    prompt.promptText = promptText.replacingOccurrences(of: oldName, with: newName)
                }
            }
        }
    }
} 