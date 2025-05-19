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
    
    /// Generates a fully rendered prompt string from the given template and context values.
    /// - Parameters:
    ///   - template: The `StoryTemplate` to use as the basis for rendering.
    ///   - context: A dictionary mapping placeholder tokens (e.g. "character.name") to replacement text.
    /// - Returns: A rendered prompt string ready to send to the story engine.
    func generatePrompt(from template: StoryTemplate, context: [String: String]) -> String {
        let raw = template.promptTemplate ?? ""
        return TemplateRenderer.render(template: raw, context: context)
    }
} 