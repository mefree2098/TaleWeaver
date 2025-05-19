import XCTest
import CoreData
@testable import TaleWeaver

@MainActor
final class SceneViewModelTests: XCTestCase {
    var container: NSPersistentContainer!
    var repository: SceneRepository!
    var viewModel: SceneViewModel!
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
        story.title = "Story"
        repository = SceneRepository(context: container.viewContext)
        viewModel = SceneViewModel(story: story, repository: repository)
    }

    override func tearDown() {
        viewModel = nil
        repository = nil
        story = nil
        container = nil
        super.tearDown()
    }

    func testAddScene() {
        viewModel.addScene(title: "One", summary: nil)
        XCTAssertEqual(viewModel.scenes.count, 1)
        XCTAssertEqual(viewModel.scenes.first?.title, "One")
    }

    func testUpdateScene() {
        let scene = viewModel.addScene(title: "Old", summary: nil)
        viewModel.updateScene(scene, title: "New", summary: "Sum")
        XCTAssertEqual(viewModel.scenes.first?.title, "New")
        XCTAssertEqual(viewModel.scenes.first?.summary, "Sum")
    }

    func testDeleteScene() {
        let scene = viewModel.addScene(title: "Temp", summary: nil)
        viewModel.deleteScene(scene)
        XCTAssertTrue(viewModel.scenes.isEmpty)
    }

    func testMoveScenes() {
        let first = viewModel.addScene(title: "First", summary: nil)
        let second = viewModel.addScene(title: "Second", summary: nil)
        _ = first; _ = second
        viewModel.moveScenes(from: IndexSet(integer: 0), to: 2)
        XCTAssertEqual(viewModel.scenes.last?.title, "First")
    }
}
