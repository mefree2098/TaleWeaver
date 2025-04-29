import CoreData

class CoreDataManager {
    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("CoreDataManager: Successfully saved context")
            } catch {
                let nsError = error as NSError
                print("CoreDataManager: Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func refreshContext() {
        persistentContainer.viewContext.refreshAllObjects()
    }
    
    func refreshObject(_ object: NSManagedObject) {
        persistentContainer.viewContext.refresh(object, mergeChanges: true)
    }
} 