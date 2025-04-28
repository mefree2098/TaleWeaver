//
//  PersistenceController.swift
//  TaleWeaver
//
//  Created by Matt Freestone on 4/27/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaleWeaver")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Preview Helper
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create sample data for previews
        let viewContext = controller.container.viewContext
        
        // Create a sample story
        let story = Story(context: viewContext)
        story.id = UUID()
        story.title = "The Adventure Begins"
        story.content = "Once upon a time in a land far away..."
        story.createdAt = Date()
        story.updatedAt = Date()
        
        // Create a sample prompt
        let prompt = StoryPrompt(context: viewContext)
        prompt.id = UUID()
        prompt.promptText = "Write a fantasy story about a hero's journey"
        prompt.createdAt = Date()
        prompt.story = story
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
} 