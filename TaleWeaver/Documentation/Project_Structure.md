# TaleWeaver Project Structure

## Overview
TaleWeaver is a SwiftUI-based iOS application for creating and managing stories with AI assistance. The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses Core Data for persistence.

## Core Components

### App Structure
- `TaleWeaverApp.swift`: Main app entry point
  - Sets up the app environment
  - Configures Core Data
  - Initializes services
- `ContentView.swift`: Root view of the application
  - Manages navigation between main sections
  - Handles app state
- `Configuration.swift`: App configuration settings
  - Manages API keys and settings
  - Provides app-wide configuration

### Core Data Model
- `TaleWeaver.xcdatamodeld`: Single source of truth for all Core Data entities
  - Story: Core Data entity for stories
  - StoryPrompt: Core Data entity for story prompts
  - StoryTemplate: Core Data entity for story templates
  - Character: Core Data entity for characters
    - isUserCharacter: Boolean flag to distinguish between user characters and story characters
    - intelligence: Integer attribute (1-10) for story characters to determine their AI capabilities

### Models
- `Character.swift`: Core Data entity for managing characters
  - Attributes: id, name, characterDescription, avatarURL, isUserCharacter, intelligence
  - Relationships: story (to Story), userStories (to Story)
- `Story.swift`: Core Data entity for managing stories
  - Attributes: id, title, content, createdAt, updatedAt
  - Relationships: prompts (to StoryPrompt), characters (to Character), userCharacter (to Character)
- `StoryPrompt.swift`: Core Data entity for managing story prompts
  - Attributes: id, content, createdAt
  - Relationships: story (to Story)
- `StoryTemplate+CoreDataClass.swift`: Base class for StoryTemplate entity
  - Implements Identifiable protocol
  - Inherits from NSManagedObject
- `StoryTemplate+CoreDataProperties.swift`: Properties and relationships for StoryTemplate
  - Attributes: id, name, templateDescription, promptTemplate, createdAt, updatedAt
  - Relationships: stories (to Story)
  - Includes generated accessors for stories relationship
- `Story+Extensions.swift`: Extensions for Story entity
  - Provides computed property for sorted prompts array
  - Sorts prompts by creation date in descending order

### ViewModels
- `CharacterViewModel.swift`: Manages character data and business logic
  - Handles CRUD operations for characters
  - Manages user vs. story character distinction
  - Updates character names throughout stories
  - Manages user character assignment to stories
- `StoryViewModel.swift`: Manages story data and business logic
  - Handles CRUD operations for stories
  - Manages story prompts and templates
  - Processes chat messages in the story transcript
- `TemplateViewModel.swift`: Manages template data and business logic
  - Handles CRUD operations for templates
  - Manages template selection and application

### Views
- `StartView.swift`: Initial view when app launches
  - Provides onboarding experience
  - Guides users through initial setup
- `StoryListView.swift`: Main view displaying list of stories
  - Shows story cards with titles and previews
  - Provides navigation to story details
  - Includes search functionality
- `StoryDetailView.swift`: Displays the details of a selected story
  - Shows story content
  - Displays chat transcript interface
  - Allows adding new messages to the conversation
  - Shows user character avatar and name with messages
- `StoryEditorView.swift`: Handles story creation and editing
  - Template selection UI (fully integrated with Core Data)
  - Prompt generation from templates
  - Story content editing
  - Story character management
- `CharacterEditorView.swift`: Handles character creation and editing
  - Manages character details
  - Handles avatar selection and generation
  - Supports both user and story characters
- `CharacterListView.swift`: Displays list of characters
  - Shows character cards with avatars
  - Provides search functionality
  - Supports navigation to character details
- `CharacterDetailView.swift`: Shows detailed character information
  - Displays character avatar and details
  - Shows associated stories
  - Provides navigation to story details
- `CharacterCustomizationView.swift`: Customizes character appearance
  - Manages character visual properties
  - Handles avatar customization
- `SettingsView.swift`: Displays app settings
  - API key configuration
  - User character management
  - App preferences
- `UserCharacterEditorView.swift`: Creates and edits user characters
  - Manages character details and avatar
  - Integrates with FullScreenImageView
  - Handles image selection and generation
- `StoryCharacterListView.swift`: Displays and manages story characters
  - Shows list of characters for a specific story
  - Shows currently assigned user character
  - Allows assigning/removing user character
  - Manages story-specific characters
  - Provides search functionality
  - Supports character deletion with confirmation
  - Refreshes view when changes occur
- `StoryCharacterEditorView.swift`: Creates and edits story characters
  - Manages character details and avatar
  - Integrates with FullScreenImageView
  - Handles image selection and generation
  - Includes intelligence slider for AI capabilities
  - Properly loads existing character data
  - Provides visual feedback for intelligence levels
- `TemplateSelectionView.swift`: Interface for selecting story templates
  - Shows available templates
  - Allows template preview
  - Supports template selection
- `NewPromptView.swift`: Allows adding new prompts to stories
  - Handles prompt input
  - Manages character selection
  - Supports prompt preview

### Components
- `CharacterRow.swift`: Reusable component for displaying character information
  - Shows character avatar and details
  - Handles both local and remote image URLs
  - Provides consistent styling for character rows
- `FullScreenImageView.swift`: Displays images in full screen
  - Handles image loading and display
  - Provides zoom and pan functionality
  - Manages image caching
- `ImagePicker.swift`: Generic image picker component
  - Uses PHPickerViewController
  - Supports image selection from photo library
  - Handles image loading and processing
- `CharacterImagePicker.swift`: Specialized image picker for characters
  - Uses UIImagePickerController
  - Supports photo library access
  - Handles image selection and processing
- `StoryCardModifier.swift`: View modifier for story cards
  - Applies consistent styling
  - Handles layout and appearance
  - Manages card interactions
- `StoryCardShape.swift`: Custom shape for story cards
  - Defines card appearance
  - Handles corner radius and shadows
  - Manages card dimensions

### Services
- `OpenAIService.swift`: Handles interactions with OpenAI API
  - Manages API configuration
  - Handles character avatar generation
  - Processes story generation requests
  - Manages API rate limits
  - Handles error responses

### Managers
- `CharacterManager.swift`: Manages character-related operations
  - Handles character creation and updates
  - Manages character relationships
  - Coordinates with repositories

### Utilities
- `FeedbackManager.swift`: Manages user feedback
  - Handles haptic feedback
  - Provides visual feedback
  - Manages error notifications
- `ImageCache.swift`: Manages image caching
  - Handles image loading and caching
  - Provides efficient image retrieval
  - Manages memory usage
- `Secrets.swift`: Manages sensitive information
  - Stores API keys
  - Handles secure data

### Core
- `PersistenceController.swift`: Manages Core Data stack
  - Sets up persistent container
  - Handles migrations
  - Manages save operations

### Repositories
- `StoryRepository.swift`: Data access layer for stories
  - Handles Core Data operations
  - Manages story persistence
  - Provides CRUD operations

### Tests
- `ImageCacheTests.swift`: Tests for image caching functionality
- `OpenAIServiceTests.swift`: Tests for OpenAI service functionality
- `StoryManagerTests.swift`: Tests for story management operations

### Documentation
- `Project_Structure.md`: Documents the project structure and organization
- `Bug_Tracking.md`: Tracks known issues and their resolutions
- `Deployment_Guide.md`: Provides guidance for deploying the application
- `Script_Adherence.md`: Tracks adherence to project requirements
- `Development_Workflow.md`: Outlines the development workflow

## Data Flow
1. User interacts with UI components
2. ViewModels process user input
3. Repositories handle data persistence
4. Services manage external API interactions
5. Core Data manages data storage
6. ViewModels update UI state

## Error Handling
- Comprehensive error handling throughout the app
- User-friendly error messages
- Graceful degradation when services are unavailable
- Data validation at all levels

## Async Operations
- Proper handling of asynchronous operations
- Loading states for UI feedback
- Error handling for async tasks
- Background processing for heavy operations

## Testing
- Unit tests for ViewModels
- Integration tests for Services
- UI tests for critical user flows
- Performance tests for image handling

## Best Practices
- MVVM architecture
- SwiftUI for modern UI
- Core Data for persistence
- Proper memory management
- Efficient image handling
- Secure API key management

## Navigation Flow
1. Settings
   - User Character Management
     - View User Characters
     - Create/Edit User Character
     - Delete User Character
2. Story Editor
   - Story Character Management
     - View Story Characters
     - Create/Edit Story Character
     - Delete Story Character
   - Template Selection
   - Story Creation/Editing
3. Story Detail
   - View Story Content
   - Chat Transcript Interface
     - View Conversation History
     - Add New Messages
     - See User Character Information

### Character Management
1. User accesses character management through Settings (user characters) or Story Editor (story characters)
2. User can create, edit, or delete characters
3. For story characters:
   - User can assign/remove user character
   - User can manage story-specific characters
   - Changes are immediately reflected in the story
4. User character information is displayed in the chat transcript:
   - Character name and avatar are shown with each message
   - If character name is updated, it automatically updates in all messages

## Current Limitations
- Template selection UI in StoryEditorView not yet fully integrated with Core Data
- Advanced template system pending implementation
- Image generation rate limits from OpenAI API
- Core Data relationship warnings need resolution
- Template selection UI needs improvement
- API rate limits for image generation
- Character name updates require manual refresh

## Future Enhancements
- Advanced template system with full Core Data integration
- Enhanced image generation capabilities
- Improved character relationship management
- Advanced story analytics
- Collaborative story creation
- Export/import functionality
- Cloud sync support
- Template system improvements
- Enhanced image generation capabilities
- Collaborative features
- Character relationship management
- Character arc tracking
- Character dialogue history
- Enhanced chat transcript features:
  - Support for multiple characters in conversation
  - Character-specific styling for messages
  - Message threading and replies
  - Rich text formatting in messages