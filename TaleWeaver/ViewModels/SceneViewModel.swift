import Foundation
import CoreData
import Combine

@MainActor
final class SceneViewModel: ObservableObject {
    // Input
    private let repository: SceneRepository
    private let story: Story

    // Output
    @Published private(set) var scenes: [Scene] = []
    @Published var errorMessage: String?

    init(story: Story, repository: SceneRepository) {
        self.story = story
        self.repository = repository
        refresh()
    }

    // MARK: Intents

    func refresh() {
        do {
            scenes = try repository.fetchScenes(for: story)
        } catch {
            errorMessage = "Failed to load scenes: \(error.localizedDescription)"
        }
    }

    func addScene(title: String, summary: String?) {
        _ = repository.createScene(for: story, title: title, summary: summary)
        persistChanges()
    }

    func updateScene(_ scene: Scene, title: String, summary: String?) {
        repository.updateScene(scene, title: title, summary: summary)
        persistChanges()
    }

    func deleteScene(_ scene: Scene) {
        repository.deleteScene(scene)
        persistChanges()
    }

    // MARK: Private

    private func persistChanges() {
        do {
            try repository.save()
            refresh()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}