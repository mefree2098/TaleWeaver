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
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        story = Story(context: container.viewContext)
        story.id = UUID()
        story.title = "Test Story"

        repository = SceneRepository(context: container.viewContext)
    }

    override func tearDown() {
        repository = nil
        story = nil
        container = nil
        super.tearDown()
    }

    func testCreateAndFetchScene() throws {
        _ = repository.createScene(for: story, title: "Intro", summary: "start")
        try repository.save()

        let scenes = try repository.fetchScenes(for: story)
        XCTAssertEqual(scenes.count, 1)
        XCTAssertEqual(scenes.first?.title, "Intro")
    }

    func testUpdateScene() throws {
        let scene = repository.createScene(for: story, title: "Intro", summary: nil)
        try repository.save()

        repository.updateScene(scene, title: "Updated", summary: "new")
        try repository.save()

        let scenes = try repository.fetchScenes(for: story)
        XCTAssertEqual(scenes.first?.title, "Updated")
        XCTAssertEqual(scenes.first?.summary, "new")
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
