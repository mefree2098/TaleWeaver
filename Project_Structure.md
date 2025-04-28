# Project Structure

## Core Components

### Models
- Story.swift: Core Data entity for stories
- StoryPrompt.swift: Core Data entity for prompts
- Story+Extensions.swift: Extensions for Story entity
  - promptsArray: Computed property to access sorted prompts
- `TaleWeaver.xcdatamodeld`: Core Data model definition

### ViewModels
- StoryViewModel.swift: Manages story data and business logic
  - Dependencies: StoryRepository, OpenAIService
  - Async operations for story generation and updates
  - Error handling and state management

### Views
- StoryListView.swift: Main list of stories
  - Search functionality
  - Story creation
  - Navigation to detail view
- StoryDetailView.swift: Story details and prompts
  - Story editing
  - Prompt management
  - Navigation to editor
- StoryEditorView.swift: Story creation and editing
  - Async story generation
  - Error handling
  - Loading states
- NewPromptView.swift: Prompt creation
  - Async prompt generation
  - Error handling
  - Loading states

### Services
- OpenAIService.swift: OpenAI API integration
  - Story generation
  - Prompt generation
  - Error handling
- ImageCache.swift: Image caching service
  - Memory management
  - Cache limits
  - Cleanup

### Repository
- StoryRepository.swift: Data persistence
  - CRUD operations
  - Relationship management
  - Error handling

### Documentation
- Project_Structure.md: Project organization
- Bug_Tracking.md: Issue tracking
- API_Documentation.md: API integration details

## Data Flow
1. User interaction in Views
2. ViewModel processes request
3. Repository/Services handle data
4. ViewModel updates state
5. Views reflect changes

## Error Handling
1. Services throw errors
2. ViewModel catches and processes
3. Views display user-friendly messages
4. Repository handles persistence errors

## Async Operations
1. Story generation
2. Prompt generation
3. Data persistence
4. Image loading

## Testing
1. StoryManagerTests
2. ImageCacheTests
3. RepositoryTests
4. ViewModelTests
5. ViewTests

## Best Practices
1. SwiftUI native components
2. Proper error handling
3. Accessibility support
4. Dark mode support
5. Memory management
6. Async/await usage
7. Dependency injection
8. Documentation
9. Test coverage
10. View initialization consistency

## Tests

### Unit Tests
- `ImageCacheTests.swift`: Tests for image caching functionality
- `StoryManagerTests.swift`: Tests for story management operations
- `OpenAIServiceTests.swift`: Tests for OpenAI service functionality

## Dependencies
- SwiftUI
- CoreData
- XCTest (for testing)

## Core Data Model
- `Story` Entity
  - Attributes:
    - id: UUID
    - title: String
    - content: String
    - createdAt: Date
    - updatedAt: Date
  - Relationships:
    - prompts: to-many relationship with StoryPrompt (inverse: story)
  - Extensions:
    - promptsArray: Computed property to access sorted prompts
- `StoryPrompt` Entity
  - Attributes:
    - id: UUID
    - promptText: String
    - createdAt: Date
  - Relationships:
    - story: to-one relationship with Story (inverse: prompts) 