import XCTest
import CoreData
@testable import TaleWeaver

final class SceneViewModelTests: XCTestCase {
    var persistence: PersistenceController!
    var context: NSManagedObjectContext!
    var repository: SceneRepository!
    var story: Story!
    var viewModel: SceneViewModel!

    override func setUp() {
        super.setUp()
        persistence = PersistenceController(inMemory: true)
        context = persistence.container.viewContext
        repository = SceneRepository(context: context)
        story = Story(context: context)
        story.id = UUID()
        story.title = "Story"
        viewModel = SceneViewModel(story: story, repository: repository)
    }

    override func tearDown() {
        persistence = nil
        context = nil
        repository = nil
        story = nil
        viewModel = nil
        super.tearDown()
    }

    func testAddScene() {
        let scene = viewModel.addScene(title: "One", summary: nil)
        XCTAssertEqual(viewModel.scenes.count, 1)
        XCTAssertEqual(scene.title, "One")
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
        _ = viewModel.addScene(title: "A", summary: nil)
        _ = viewModel.addScene(title: "B", summary: nil)
        viewModel.moveScenes(from: IndexSet(integer: 0), to: 1)
        XCTAssertEqual(viewModel.scenes.first?.title, "B")
    }
}
