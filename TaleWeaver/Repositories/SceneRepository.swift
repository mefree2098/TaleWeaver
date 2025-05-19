import CoreData
import Foundation

/// Repository responsible for CRUD operations on Scene objects.
final class SceneRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: Create

    func createScene(for story: Story, title: String, summary: String?) -> Scene {
        let scene = Scene(context: context)
        scene.id = UUID()
        scene.title = title
        scene.summary = summary
        scene.createdAt = Date()
        scene.updatedAt = Date()
        scene.story = story
        return scene
    }

    // MARK: Fetch

    func fetchScenes(for story: Story) throws -> [Scene] {
        let request = Scene.fetchRequest()
        request.predicate = NSPredicate(format: "story == %@", story)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Scene.createdAt, ascending: true)]
        return try context.fetch(request)
    }

    // MARK: Update

    func updateScene(_ scene: Scene, title: String, summary: String?) {
        scene.title = title
        scene.summary = summary
        scene.updatedAt = Date()
    }

    // MARK: Delete

    func deleteScene(_ scene: Scene) {
        context.delete(scene)
    }

    // MARK: Save Helper

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}