# TaleWeaver Project Structure

## Overview
TaleWeaver is a SwiftUI-based iOS application for creating and managing stories with AI assistance. The app follows the MVVM (Model-View-ViewModel) architecture pattern and uses Core Data for persistence.

## Core Components

### Core Data Model
- TaleWeaver.xcdatamodeld: Single source of truth for all Core Data entities
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
- `StoryTemplate.swift`: Core Data entity for managing story templates
  - Attributes: id, name, description, content
  - Relationships: stories (to Story)

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
- StoryListView.swift: Main view displaying list of stories
- StoryDetailView.swift: Displays the details of a selected story
  - Shows story content
  - Displays chat transcript interface
  - Allows adding new messages to the conversation
  - Shows user character avatar and name with messages
- StoryEditorView.swift: Handles story creation and editing
  - Template selection UI (fully integrated with Core Data)
  - Prompt generation from templates
  - Story content editing
  - Story character management
- CharacterEditorView.swift: Handles character creation and editing with image selection and avatar generation
- CharacterListView.swift: Displays list of characters with search functionality
- CharacterDetailView.swift: Shows detailed character information and associated stories
- SettingsView.swift: Displays app settings, API key configuration, and user character management
- `UserCharacterListView.swift`: Displays and manages user characters
  - Shows list of user characters
  - Allows searching and filtering
  - Provides navigation to character editor
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
  - Supports adding, editing, and deleting characters
- `StoryCharacterEditorView.swift`: Creates and edits story characters
  - Manages character details and avatar
  - Integrates with FullScreenImageView
  - Handles image selection and generation
  - Includes intelligence slider for AI capabilities
- `FullScreenImageView.swift`: Displays images in full screen
  - Handles image loading and display
  - Provides zoom and pan functionality
  - Manages image caching
- NewPromptView.swift: Allows adding new prompts to stories
- TemplateSelectionView.swift: Interface for selecting story templates

### Components
- CharacterImagePicker.swift: Custom image picker for character avatars
- StoryCardShape.swift: Custom shape for story cards
- StoryCardModifier.swift: View modifier for story card styling
- TemplateCard.swift: Reusable component for displaying story templates
- ChatMessageView.swift: Displays a chat message with user character information
  - Shows character avatar
  - Displays character name
  - Shows message content
  - Includes timestamp

### Services
- `OpenAIService.swift`: Handles interactions with OpenAI API
  - Manages API configuration
  - Handles character avatar generation
  - Processes story generation requests
- `ImageCache.swift`: Manages image caching
  - Handles image loading and caching
  - Provides efficient image retrieval
  - Manages memory usage

### Repositories
- `CharacterRepository.swift`: Data access layer for characters
  - Handles Core Data operations
  - Manages character persistence
- `StoryRepository.swift`: Data access layer for stories
  - Handles Core Data operations
  - Manages story persistence
- `TemplateRepository.swift`: Data access layer for templates
  - Handles Core Data operations
  - Manages template persistence

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