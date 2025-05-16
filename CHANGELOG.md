# Changelog

All notable changes to TaleWeaver will be documented in this file.

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
