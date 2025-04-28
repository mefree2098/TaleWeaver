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

### Models
- Story+Extensions.swift: Extensions for Story entity
  - promptsArray: Computed property to access sorted prompts
- StoryTemplate+CoreDataClass.swift: Core Data class for StoryTemplate entity
- StoryTemplate+CoreDataProperties.swift: Core Data properties for StoryTemplate entity

### ViewModels
- StoryViewModel.swift: Manages story data and business logic
  - Dependencies: StoryRepository, OpenAIService
  - Handles story CRUD operations
  - Manages async operations for story generation
- CharacterViewModel.swift: Manages character data and business logic
  - Handles character CRUD operations
  - Distinguishes between user characters and story characters
  - Updates character names throughout stories when changed
- TemplateViewModel.swift: Manages story templates
  - Handles template loading and selection
  - Generates prompts from templates
  - Manages template persistence

### Views
- StoryListView.swift: Main view displaying list of stories
- StoryDetailView.swift: Displays the details of a selected story and its prompts
- StoryEditorView.swift: Handles story creation and editing
  - Template selection UI (fully integrated with Core Data)
  - Prompt generation from templates
  - Story content editing
  - Story character management
- CharacterEditorView.swift: Handles character creation and editing with image selection and avatar generation
- CharacterListView.swift: Displays list of characters with search functionality
- CharacterDetailView.swift: Shows detailed character information and associated stories
- SettingsView.swift: Displays app settings, API key configuration, and user character management
- UserCharacterListView.swift: Displays list of user characters
- UserCharacterEditorView.swift: Handles user character creation and editing
- StoryCharacterListView.swift: Displays and manages characters for a specific story
- StoryCharacterEditorView.swift: Handles story character creation and editing
- NewPromptView.swift: Allows adding new prompts to stories
- TemplateSelectionView.swift: Interface for selecting story templates

### Components
- CharacterImagePicker.swift: Custom image picker for character avatars
- StoryCardShape.swift: Custom shape for story cards
- StoryCardModifier.swift: View modifier for story card styling
- TemplateCard.swift: Reusable component for displaying story templates

### Services
- OpenAIService.swift: Handles communication with OpenAI API
- ImageCache.swift: Manages image caching and loading

### Repository
- StoryRepository.swift: Handles data persistence and Core Data operations

## Data Flow
1. User creates/edits story in StoryEditorView
2. Template selection (if creating new story)
3. StoryViewModel processes the request
4. StoryRepository persists the data
5. UI updates to reflect changes

## Error Handling
- Comprehensive error handling in ViewModels
- User-friendly error messages in Views
- Proper error propagation through the app

## Async Operations
- Story generation
- Image loading and caching
- Character avatar generation
- Template prompt generation

## Testing
- Unit tests for ViewModels
- Integration tests for Repository
- UI tests for critical user flows

## Best Practices
- MVVM architecture
- SwiftUI for UI components
- Core Data for persistence
  - Single source of truth for data model
  - Proper entity relationships
  - Consistent naming conventions
- Proper dependency injection
- Comprehensive error handling
- Accessibility support
- Documentation maintenance

## Navigation Flow
1. Story List
   - View all stories
   - Create new story
   - Select story to view/edit
2. Story Detail
   - View story content
   - Add new prompts
   - Edit story
   - Manage story characters
3. Story Editor
   - Select template (new stories)
   - Edit story content
   - Generate prompts
   - Add/edit story characters
4. Character Management
   - User Characters (in Settings)
     - Create/edit user character
     - Manage user character
   - Story Characters (in Story Editor)
     - Create/edit story characters
     - Assign characters to stories
5. Settings
   - User Character Management
     - User Character List
     - User Character Editor
   - API Configuration

## Current Limitations
- Limited character-story relationship management
- Single API key configuration

## Future Enhancements
- Enhanced character creation and customization
- Multiple API key support
- Improved story generation
- Better character-story relationships