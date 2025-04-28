import Foundation
import CoreData

class CharacterManager {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createCharacter(name: String, description: String, avatarURL: String?) -> Character {
        let character = Character(context: context)
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        character.createdAt = Date()
        
        do {
            try context.save()
        } catch {
            print("Error saving character: \(error)")
        }
        
        return character
    }
    
    func fetchCharacters() -> [Character] {
        let request: NSFetchRequest<Character> = Character.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Character.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching characters: \(error)")
            return []
        }
    }
    
    func deleteCharacter(_ character: Character) {
        context.delete(character)
        
        do {
            try context.save()
        } catch {
            print("Error deleting character: \(error)")
        }
    }
    
    func updateCharacter(_ character: Character, name: String, description: String, avatarURL: String?) {
        character.name = name
        character.characterDescription = description
        character.avatarURL = avatarURL
        
        do {
            try context.save()
        } catch {
            print("Error updating character: \(error)")
        }
    }
    
    func addCharacterToStory(_ character: Character, story: Story) {
        story.addToCharacters(character)
        
        do {
            try context.save()
        } catch {
            print("Error adding character to story: \(error)")
        }
    }
    
    func removeCharacterFromStory(_ character: Character, story: Story) {
        story.removeFromCharacters(character)
        
        do {
            try context.save()
        } catch {
            print("Error removing character from story: \(error)")
        }
    }
} 