import XCTest
import CoreData
@testable import TaleWeaver

class CoreDataMigrationTests: XCTestCase {

    func testMigrationOptionsAreEnabledOnPersistentStoreDescription() {
        // Given
        let container = PersistenceController.shared.container
        guard let storeDescription = container.persistentStoreDescriptions.first else {
            XCTFail("Persistent store description not found")
            return
        }

        // Then
        let migrateAutomatically = storeDescription.options?[NSMigratePersistentStoresAutomaticallyOption] as? Bool
        let inferMapping = storeDescription.options?[NSInferMappingModelAutomaticallyOption] as? Bool
        XCTAssertEqual(migrateAutomatically, true, "Lightweight migration should be enabled automatically")
        XCTAssertEqual(inferMapping, true, "Mapping model inference should be enabled automatically")
    }

    func testLoadPersistentStoresSucceeds() {
        // Verify that the persistent container can load stores without errors
        let expectation = self.expectation(description: "Persistent store loads successfully")

        let container = NSPersistentContainer(name: "TaleWeaverTest")
        if let description = container.persistentStoreDescriptions.first {
            description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

            // Use an in-memory store for test
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { desc, error in
            XCTAssertNil(error, "Loading persistent stores should not produce an error, but got \(error!.localizedDescription)")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // TODO: Add test for migrating a bundled v1 store to the current model
}
