import XCTest
import CoreData
@testable import TaleWeaver

@MainActor
final class SceneViewModelTests: XCTestCase {
    var container: NSPersistentContainer!
    var repository: SceneRepository!
    var story: Story!
    var viewModel: SceneViewModel!

    override func setUp() {
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
        story.title = "Test"
        story.createdAt = Date()
        viewModel = SceneViewModel(story: story, repository: repository)
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        story = nil
        container = nil
    }

    func testAddScene() {
        let scene = viewModel.addScene(title: "A", summary: nil)
        XCTAssertEqual(viewModel.scenes.count, 1)
        XCTAssertEqual(scene.title, "A")
    }

    func testUpdateScene() {
        let scene = viewModel.addScene(title: "A", summary: nil)
        viewModel.updateScene(scene, title: "B", summary: "desc")
        XCTAssertEqual(viewModel.scenes.first?.title, "B")
        XCTAssertEqual(viewModel.scenes.first?.summary, "desc")
    }

    func testDeleteScene() {
        let scene = viewModel.addScene(title: "A", summary: nil)
        viewModel.deleteScene(scene)
        XCTAssertTrue(viewModel.scenes.isEmpty)
    }
}
