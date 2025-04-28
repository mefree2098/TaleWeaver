import Foundation
import CoreData
import SwiftUI

class TemplateViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var templates: [StoryTemplate] = []
    @Published var errorMessage: String?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        loadDefaultTemplates()
        fetchTemplates()
    }
    
    func fetchTemplates() {
        let request = NSFetchRequest<StoryTemplate>(entityName: "StoryTemplate")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StoryTemplate.name, ascending: true)]
        
        do {
            templates = try context.fetch(request)
        } catch {
            print("Error fetching templates: \(error)")
            templates = []
        }
    }
    
    private func loadDefaultTemplates() {
        let defaultTemplates = [
            ("Adventure", "A thrilling journey filled with excitement and challenges", "Write an adventure story about [character] who discovers [discovery] and must overcome [challenge]."),
            ("Mystery", "A puzzling tale with clues and revelations", "Create a mystery story where [character] investigates [mystery] and uncovers [revelation]."),
            ("Fantasy", "A magical story in a world of imagination", "Tell a fantasy story about [character] who possesses [magical power] and must [quest]."),
            ("Science Fiction", "A futuristic tale of technology and discovery", "Write a sci-fi story where [character] encounters [technology] and faces [conflict]."),
            ("Romance", "A story of love and relationships", "Create a romance story about [character] who meets [love interest] and must overcome [obstacle]."),
            ("Horror", "A spine-chilling tale of fear and suspense", "Tell a horror story where [character] confronts [terror] in [setting].")
        ]
        
        let request = NSFetchRequest<StoryTemplate>(entityName: "StoryTemplate")
        
        do {
            let count = try context.count(for: request)
            if count == 0 {
                for (name, description, promptTemplate) in defaultTemplates {
                    let template = StoryTemplate(context: context)
                    template.id = UUID()
                    template.name = name
                    template.templateDescription = description
                    template.promptTemplate = promptTemplate
                    template.createdAt = Date()
                }
                saveContext()
            }
        } catch {
            print("Error checking templates: \(error)")
        }
    }
    
    func createTemplate(name: String, description: String, promptTemplate: String) {
        let template = StoryTemplate(context: context)
        template.id = UUID()
        template.name = name
        template.templateDescription = description
        template.promptTemplate = promptTemplate
        template.createdAt = Date()
        
        saveContext()
        fetchTemplates()
    }
    
    func updateTemplate(_ template: StoryTemplate, name: String, description: String, promptTemplate: String) {
        template.name = name
        template.templateDescription = description
        template.promptTemplate = promptTemplate
        template.updatedAt = Date()
        
        saveContext()
        fetchTemplates()
    }
    
    func deleteTemplate(_ template: StoryTemplate) {
        context.delete(template)
        saveContext()
        fetchTemplates()
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
    
    func generatePrompt(from template: StoryTemplate, with character: Character? = nil) -> String {
        guard var prompt = template.promptTemplate else { return "" }
        
        if let character = character {
            prompt = prompt.replacingOccurrences(of: "[character]", with: character.name ?? "the protagonist")
        } else {
            prompt = prompt.replacingOccurrences(of: "[character]", with: "the protagonist")
        }
        
        // Replace other placeholders with random options
        let discoveries = ["an ancient artifact", "a hidden doorway", "a mysterious map", "a secret message"]
        let challenges = ["a powerful enemy", "a natural disaster", "a difficult puzzle", "a moral dilemma"]
        let mysteries = ["a disappearance", "an unsolved crime", "a strange phenomenon", "a hidden conspiracy"]
        let revelations = ["a shocking truth", "a hidden connection", "a dark secret", "an unexpected ally"]
        let magicalPowers = ["the ability to control time", "the power of elemental magic", "telepathic abilities", "shape-shifting powers"]
        let quests = ["save the kingdom", "break an ancient curse", "restore balance to the world", "find a legendary artifact"]
        let technologies = ["artificial intelligence", "time travel device", "advanced robotics", "alien technology"]
        let conflicts = ["ethical dilemma", "technological disaster", "hostile alien species", "corrupt corporation"]
        let obstacles = ["social differences", "family opposition", "distance", "past relationships"]
        let terrors = ["supernatural entity", "psychological horror", "ancient curse", "mysterious stalker"]
        let settings = ["abandoned mansion", "remote island", "underground facility", "haunted forest"]
        
        prompt = prompt.replacingOccurrences(of: "[discovery]", with: discoveries.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[challenge]", with: challenges.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[mystery]", with: mysteries.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[revelation]", with: revelations.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[magical power]", with: magicalPowers.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[quest]", with: quests.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[technology]", with: technologies.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[conflict]", with: conflicts.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[obstacle]", with: obstacles.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[terror]", with: terrors.randomElement() ?? "")
        prompt = prompt.replacingOccurrences(of: "[setting]", with: settings.randomElement() ?? "")
        
        return prompt
    }
} 