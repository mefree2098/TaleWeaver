# Project Structure

## Core Components

### Models
- `Story.swift`: Core Data entity for stories
- `StoryPrompt.swift`: Core Data entity for story prompts
- `Character.swift`: Core Data entity for characters
- `Story+Extensions.swift`: Extensions for Story entity
  - `promptsArray`: Computed property to access sorted prompts

### ViewModels
- `StoryViewModel.swift`: Manages story data and business logic
  - Dependencies: StoryRepository, OpenAIService
  - Async operations: Story generation, image loading
- `CharacterViewModel.swift`: Manages character data and business logic
  - Dependencies: Core Data context
  - Operations: CRUD operations for characters

### Views
- `StoryListView.swift`: Main list of stories
  - Dependencies: StoryViewModel
  - Features: Search, filtering, sorting
- `StoryDetailView.swift`: Detailed view of a story
  - Dependencies: StoryViewModel
  - Features: Story content, prompts, sharing
- `StoryEditorView.swift`: Editor for creating/editing stories
  - Dependencies: StoryViewModel
  - Features: Rich text editing, prompt management
- `CharacterListView.swift`: List of characters
  - Dependencies: CharacterViewModel
  - Features: Search, filtering, sorting
- `CharacterCustomizationView.swift`: Editor for creating/editing characters
  - Dependencies: CharacterViewModel
  - Features: Character details, image selection
- `CharacterEditorView.swift`: Alternative editor for creating/editing characters
  - Dependencies: CharacterViewModel
  - Features: Character details, image selection

### Components
- `CharacterImagePicker.swift`: Reusable image picker for character avatars
  - Features: Photo library access, image selection

### Services
- `OpenAIService.swift`: Handles OpenAI API communication
  - Features: Story generation, image generation
- `ImageCache.swift`: Manages image caching
  - Features: Memory-efficient image storage

### Repository
- `StoryRepository.swift`: Data persistence layer
  - Features: Core Data operations, error handling

## Data Flow
1. User interactions trigger view model methods
2. View models coordinate with services and repositories
3. Repositories handle data persistence
4. Services manage external API communication
5. Changes are reflected back to the UI through published properties

## Error Handling
1. Comprehensive error handling in services
2. User-friendly error messages in views
3. Proper Core Data error handling
4. Network error handling in API services

## Async Operations
1. Story generation using OpenAI
2. Image loading and caching
3. Core Data operations
4. Network requests

## Testing
1. Unit tests for view models
2. Integration tests for services
3. UI tests for critical flows
4. Performance testing for image cache

## Best Practices
1. MVVM architecture
2. SwiftUI for UI components
3. Core Data for persistence
4. Proper error handling
5. Comprehensive documentation
6. Regular testing
7. Memory management
8. Accessibility support