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

    // MARK: AI helpers

    func generateDescription(for prompt: String) async -> String? {
        do {
            let txt = try await OpenAIService.shared.generateStory(prompt: "Generate a vivid scene description: \(prompt)")
            return txt.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            await MainActor.run { self.errorMessage = error.localizedDescription }
            return nil
        }
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
            // Notify observers of parent story so StoryDetailView refreshes its scenes list
            story.objectWillChange.send()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}