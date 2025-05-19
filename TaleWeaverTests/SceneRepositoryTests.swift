import XCTest
import CoreData
@testable import TaleWeaver

final class SceneRepositoryTests: XCTestCase {
    var persistence: PersistenceController!
    var context: NSManagedObjectContext!
    var repository: SceneRepository!
    var story: Story!

    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
        repository = SceneRepository(context: context)
        story = Story(context: context)
        story.id = UUID()
        story.title = "Story"
    }

    override func tearDown() {
        persistence = nil
        context = nil
        repository = nil
        story = nil
        super.tearDown()
    }

    func testCreateAndFetchScene() throws {
        _ = repository.createScene(for: story, title: "Scene", summary: nil)
        try repository.save()

        let scenes = try repository.fetchScenes(for: story)
        XCTAssertEqual(scenes.count, 1)
        XCTAssertEqual(scenes.first?.title, "Scene")
    }

    func testUpdateScene() throws {
        let scene = repository.createScene(for: story, title: "A", summary: "B")
        try repository.save()

        repository.updateScene(scene, title: "New", summary: "C")
        try repository.save()

        let fetched = try repository.fetchScenes(for: story)
        XCTAssertEqual(fetched.first?.title, "New")
        XCTAssertEqual(fetched.first?.summary, "C")
    }

    func testDeleteScene() throws {
        let scene = repository.createScene(for: story, title: "Temp", summary: nil)
        try repository.save()

        repository.deleteScene(scene)
        try repository.save()

        let scenes = try repository.fetchScenes(for: story)
        XCTAssertTrue(scenes.isEmpty)
    }
}
