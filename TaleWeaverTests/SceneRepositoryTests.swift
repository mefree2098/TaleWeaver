import XCTest
import CoreData
@testable import TaleWeaver

final class SceneRepositoryTests: XCTestCase {
    var container: NSPersistentContainer!
    var repository: SceneRepository!
    var story: Story!

    override func setUp() {
        super.setUp()
        container = NSPersistentContainer(name: "TaleWeaver")
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        repository = SceneRepository(context: container.viewContext)
        story = Story(context: container.viewContext)
        story.id = UUID()
        story.title = "Test Story"
        story.createdAt = Date()
    }

    override func tearDown() {
        repository = nil
        story = nil
        container = nil
        super.tearDown()
    }

    func testCreateScene() throws {
        _ = repository.createScene(for: story, title: "Intro", summary: "desc")
        try repository.save()
        let scenes = try repository.fetchScenes(for: story)
        XCTAssertEqual(scenes.count, 1)
        XCTAssertEqual(scenes.first?.title, "Intro")
    }

    func testUpdateScene() throws {
        let scene = repository.createScene(for: story, title: "Intro", summary: nil)
        try repository.save()
        repository.updateScene(scene, title: "Updated", summary: "New")
        try repository.save()
        XCTAssertEqual(scene.title, "Updated")
        XCTAssertEqual(scene.summary, "New")
    }

    func testDeleteScene() throws {
        let scene = repository.createScene(for: story, title: "Intro", summary: nil)
        try repository.save()
        repository.deleteScene(scene)
        try repository.save()
        let scenes = try repository.fetchScenes(for: story)
        XCTAssertTrue(scenes.isEmpty)
    }
}
