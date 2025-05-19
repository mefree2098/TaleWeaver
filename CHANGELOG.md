# Changelog

All notable changes to TaleWeaver will be documented in this file.

## TODO – Next Steps (Scenes & AI integration) – 2025-05-18

### 0 Delete Capabilty
-   Add ability in UI )to delete scenes, stories, and user characters.

### 1 Scene Workflow
- **SceneListView** refreshes after save; remaining
  - Optional drag-to-reorder scenes
- **SceneDetailView**
  1. Toolbar “Add Character” opens picker and inserts system prompt “<Name> enters the scene>”.
  2. Show active-character chips / avatars at top.
  3. Ability to remove a character (optional).
- **SceneEditorView**
  - Multi-select character assignment when creating / editing a scene.

### 2 Character Workflow
- **StoryCharacterListView**
  - When both user & story sections are empty show placeholder with “+ Add Character” button.

### 3 AI / OpenAI
- Surface `OpenAIError.apiError(message)` to user.
- Add dedicated `generateSceneDescription(theme:)` wrapper (currently re-uses `generateStory`).

### 4 Core Data / Migration
- Optional debug toggle: wipe store automatically when migration fails (dev builds only).
- Consider background context for chat message inserts to avoid UI hitch.

### 5 UI & Accessibility
- Resolve system keyboard accessory AutoLayout warnings.
- Dark-mode review of new views.

### 6 Cleanup / Tests
- [x] Remove unused chat code from StoryDetailView.
- [x] Extract `ChatMessageView` into its own file.
- [x] Unit tests for `SceneRepository` and `SceneViewModel`.

## [1.0.0] - 2025-05-15
### Added
- Core Data inverse relationships and lightweight migration support
- Template engine v1 with placeholder rendering and unit tests
- OpenAIQueue for rate-limit handling with exponential back-off
- Haptic feedback and SwiftUI animations for key UI actions
- UI tests covering story creation and chat interface
- CI workflow with SwiftLint, unit tests, and UI tests
- Performance baseline report and ImageCache eviction policy
- Comprehensive Refinement Guide documenting end-to-end steps

### Changed
- Project documentation updated (Project_Structure, Deployment_Guide, ADRs)
- Refactored TemplateViewModel to use TemplateRenderer
- OpenAIService integration updated to use OpenAIQueue

### Fixed
- Core Data warnings and merge policies
- Character list and delete UI haptics
- AsyncImage performance and caching

### Removed
- Deprecated placeholder replacement logic in TemplateViewModel
