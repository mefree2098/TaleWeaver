import Foundation
import CoreData
import SwiftUI

class CharacterViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var characters: [Character] = []
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
        } catch {
            print("Error fetching characters: \(error)")
            characters = []
        }
    }
    
    func createCharacter(name: String, description: String, avatarURL: String?) {
        let character = Character(context: context)
        character.id = UUID()
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        character.createdAt = Date()
        
        saveContext()
        fetchCharacters()
    }
    
    func updateCharacter(_ character: Character, name: String, description: String, avatarURL: String?) {
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        character.updatedAt = Date()
        
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
    
    func generateCharacterAvatar(name: String) async throws -> String {
        return try await openAIService.generateCharacterAvatar(description: name)
    }
} 