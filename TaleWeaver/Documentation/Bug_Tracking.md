# Bug Tracking

## Test Coverage
- [x] StoryManager
- [x] ImageCache
- [x] StoryRepository
- [x] StoryViewModel
- [x] UI Components
- [ ] TemplateViewModel
- [ ] TemplateSelectionView

## Active Issues

### Character-Story Relationship Management
- Status: Resolved
- Description: Limited functionality for managing relationships between characters and stories
- Impact: Users cannot easily track which characters appear in which stories
- Solution: 
  1. Separated user characters from story characters
  2. Added character management within StoryEditorView
  3. Implemented automatic name updates throughout stories
- Prevention: Maintain clear separation between user and story-specific data

## Known Issues

### Character Management
- Status: Resolved
- Description: Character customization functionality needed to be integrated into SettingsView
- Solution: Added navigation from SettingsView to CharacterListView and CharacterEditorView
- Prevention: Keep UI components modular and maintain clear navigation hierarchy

### Image Handling
- Status: Resolved
- Description: Character avatars needed full-screen viewing capability
- Solution: Implemented FullScreenImageView with zoom and pan functionality
- Prevention: Consider image viewing requirements when designing UI components

### Core Data Relationships
- Status: Pending
- Description: Core Data relationship warnings for Story.prompts and StoryPrompt.story
- Solution: Need to properly configure inverse relationships
- Prevention: Always set up proper inverse relationships in Core Data model

### Character Name Updates
- Status: Resolved
- Description: Character name changes not reflected in story content
- Solution: Implemented name update propagation through story content
- Prevention: Track variable references in content and update accordingly

### Image Generation
- Status: Known Issue
- Description: OpenAI API rate limits for image generation
- Solution: Implement caching and rate limiting
- Prevention: Add proper error handling and user feedback

### Build Errors in Character Views
- Status: Resolved
- Description: Multiple build errors in StoryCharacterEditorView and UserCharacterEditorView
- Impact: Build failed due to invalid redeclarations, missing parameters, and incorrect relationships
- Solution: 
  1. Created new view files with different names to avoid redeclaration conflicts
  2. Fixed CharacterViewModel initialization to include required context parameter
  3. Corrected relationship handling between Character and Story entities
  4. Added missing ImagePicker component
  5. Added shared instance to OpenAIService
- Prevention: 
  1. Avoid duplicate view declarations across the codebase
  2. Ensure proper initialization of ViewModels with required parameters
  3. Verify Core Data relationships match the model definition
  4. Document component dependencies clearly

### StoryTemplate Entity Duplication
- Status: Resolved
- Description: Multiple StoryTemplate entity definitions causing build errors
- Impact: Build failed due to ambiguous type lookup and duplicate output files
- Solution: 
  1. Updated Core Data model to use manual code generation for StoryTemplate
  2. Verified manual Core Data files (StoryTemplate+CoreDataClass.swift and StoryTemplate+CoreDataProperties.swift)
  3. Cleaned build folder to remove conflicting artifacts
- Prevention: 
  1. Never mix automatic and manual code generation for Core Data entities
  2. Use consistent code generation strategy across the project
  3. Document code generation strategy in project documentation

### Build Errors in StoryEditorView
- Status: Resolved
- Description: Multiple build errors in StoryEditorView.swift related to character management
- Impact: Build failed due to scope issues and type mismatches
- Solution: 
  1. Fixed story scope issue in sheet presentation by using proper pattern matching with if case
  2. Fixed character creation and relationship handling by properly retrieving the created character
  3. Ensured proper parameter types for Core Data relationship methods
- Prevention: 
  1. Always use proper pattern matching for enum cases in SwiftUI views
  2. Verify return types of methods and handle them appropriately
  3. Ensure proper parameter types for Core Data relationship methods
  4. Test character creation and relationship handling thoroughly

### View Initialization Conflict
- Status: Resolved
- Description: Conflict between StoryEditorView initializers
- Solution: Consolidated initializers and added proper state management
- Prevention: Review view initialization patterns before adding new features

### NewPromptView Build Error
- Status: Resolved
- Description: Missing required parameter in StoryViewModel initialization
- Solution: Added required repository and openAIService parameters
- Prevention: Document required dependencies for view models

### Core Data Relationship Management
- Status: Resolved
- Description: Build errors related to Core Data relationship handling and optional binding
- Impact: Build failed due to type mismatches and incorrect relationship management
- Solution: 
  1. Modified CharacterViewModel.createCharacter to return the created Character
  2. Fixed optional binding for avatarURL using proper nil coalescing
  3. Updated Core Data relationship handling using NSMutableSet
- Prevention: 
  1. Always return created objects from Core Data creation methods
  2. Use proper optional binding patterns
  3. Follow Core Data best practices for relationship management
  4. Document Core Data patterns in the codebase

### Character Creation Return Value Handling
- Status: Resolved
- Description: Build error and warnings related to character creation return values and optional handling
- Impact: Build error in StoryEditorView and warnings in character-related views
- Solution: 
  1. Fixed optional handling for avatarURL in StoryEditorView
  2. Updated all character creation calls to properly handle return values
  3. Maintained proper character creation functionality across all views
- Prevention: 
  1. Always handle return values from Core Data creation methods
  2. Use proper optional handling patterns
  3. Maintain consistency across similar functionality in different views
  4. Document return value handling patterns in the codebase

### Character Editing and Image Generation
- Status: Resolved
- Description: Issues with character editing and image generation functionality
- Impact: Users couldn't edit existing characters and were prompted to upload images
- Solution: 
  1. Removed image picker functionality from character editors
  2. Fixed character editing by properly handling update vs. create in saveCharacter methods
  3. Simplified avatar generation to be the only option
- Prevention: 
  1. Ensure proper handling of edit vs. create scenarios
  2. Keep UI focused on core functionality
  3. Test character editing flow thoroughly
  4. Document character management patterns

### Story Character Editing
- Status: Resolved
- Description: Issues with story character editing and image generation functionality
- Impact: Users couldn't edit existing story characters and were prompted to upload images
- Solution: 
  1. Removed image picker functionality from StoryCharacterEditorView
  2. Fixed story character editing by properly handling update vs. create in saveCharacter method
  3. Simplified avatar generation to be the only option
  4. Updated navigation title to reflect edit mode
- Prevention: 
  1. Apply consistent patterns across user and story character management
  2. Ensure proper handling of edit vs. create scenarios
  3. Keep UI focused on core functionality
  4. Test character editing flow thoroughly

### Story Character Editor Bug
- Status: Resolved
- Description: Bug in StoryCharacterEditorView where character property was missing
- Impact: Build error and inability to edit story characters
- Solution: 
  1. Added character property to StoryCharacterEditorView
  2. Updated initializer to accept and initialize character property
  3. Modified StoryCharacterListView to pass selected character to editor
  4. Updated character selection flow to open editor instead of toggling
- Prevention: 
  1. Ensure all properties used in methods are properly defined
  2. Maintain consistent patterns between user and story character management
  3. Test character editing flow thoroughly
  4. Document component dependencies clearly

### Character Management Integration
- Status: Resolved
- Description: Character management needed to be separated between user and story characters
- Solution: Implemented distinct views and logic for user vs. story characters
- Prevention: Consider data model relationships when designing features

### Image Caching
- Status: Resolved
- Description: Character avatars were being reloaded unnecessarily
- Solution: Implemented ImageCache service
- Prevention: Always implement proper caching for network resources

### Navigation Flow
- Status: Resolved
- Description: Character management navigation was unclear
- Solution: Reorganized navigation to separate user and story character management
- Prevention: Maintain clear and intuitive navigation hierarchy

### User Character Assignment
- **Status**: Implemented
- **Description**: User characters can now be assigned to stories, but there may be edge cases to handle
- **Impact**: Medium
- **Solution**: Implemented user character assignment in StoryCharacterListView
- **Prevention**: Added proper Core Data relationship management and UI feedback

### Character Data Loading
- **Status**: Fixed
- **Description**: Character data was not loading properly in editor views
- **Impact**: High
- **Solution**: Improved state management and data loading in character editor views
- **Prevention**: Added comprehensive logging and proper initialization

### CoreGraphics NaN Errors
- **Status**: Fixed
- **Description**: Invalid numeric values being passed to CoreGraphics API
- **Impact**: Medium
- **Solution**: Fixed layout constraints and removed fixed heights
- **Prevention**: Added proper layout management and size constraints

### StoryCharacterListView Initialization Error
- **Status**: Fixed
- **Description**: Build error in StoryEditorView.swift due to extra 'viewModel' parameter in StoryCharacterListView initialization
- **Impact**: Medium
- **Solution**: Removed the viewModel parameter from StoryCharacterListView initialization as it's not part of the view's initializer
- **Prevention**: Always check view initializers before passing parameters

## Resolved Issues

### Character Editor Empty Fields
- **Status**: Resolved
- **Description**: Character editor fields were empty when editing existing characters
- **Impact**: High
- **Solution**: Improved state initialization and data loading
- **Prevention**: Added proper state management and logging

### API Key Handling
- **Status**: Resolved
- **Description**: API key was not being properly accessed from UserDefaults
- **Impact**: High
- **Solution**: Updated OpenAIService to properly handle API key
- **Prevention**: Added proper error handling and key management

## Best Practices

### Core Data
- Use proper relationships between entities
- Implement proper error handling for Core Data operations
- Use computed properties for derived data
- Maintain data consistency across relationships
- Always define entities in the Core Data model before using them in code
- Use consistent code generation strategy (either manual or automatic, not both)
- Document code generation choices in project documentation

### Memory Management
- Properly handle image caching
- Clean up resources when views are dismissed
- Use weak references where appropriate
- Monitor memory usage during async operations

### Documentation
- Keep Project_Structure.md up to date
- Document all known issues in Bug_Tracking.md
- Maintain clear documentation of dependencies
- Document Core Data model relationships

### Naming Conventions
- Use clear, descriptive names for views, models, and view models
- Follow Swift naming conventions
- Use consistent naming patterns across the project
- Document any deviations from standard naming conventions

### SwiftUI
- Use proper state management
- Implement proper view lifecycle handling
- Follow SwiftUI best practices for view composition
- Use appropriate view modifiers

### Accessibility
- Implement proper accessibility labels
- Support Dynamic Type
- Ensure proper contrast ratios
- Support VoiceOver navigation

## Testing Status

### Completed Tests
- StoryViewModel basic operations
- StoryRepository Core Data operations
- ImageCache functionality
- Basic UI component tests

### Pending Tests
- Template integration
- Character management
- Story generation
- Accessibility testing 

## Future Considerations

### Performance Optimization
- Need to monitor image loading and caching performance
- Consider implementing lazy loading for character lists
- Optimize Core Data fetch requests

### Error Handling
- Improve error messages for image generation failures
- Add retry mechanisms for failed API calls
- Implement better offline support

### User Experience
- Add loading indicators for image operations
- Improve feedback for character name updates
- Enhance image viewing experience

### Data Management
- Consider implementing data versioning
- Add data migration support
- Implement backup and restore functionality

### Character Management
- Implement character relationship tracking
- Add character arc management
- Improve character dialogue history
- Add character template system

### Performance
- Optimize Core Data relationships
- Improve image loading and caching
- Enhance search functionality

### UI/UX
- Add character relationship visualization
- Improve character editor layout
- Add character statistics and analytics 