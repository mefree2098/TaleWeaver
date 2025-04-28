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
- Character Customization Integration
  - Status: Resolved
  - Description: Character customization functionality needed to be integrated into SettingsView
  - Solution: Added CharacterListView and CharacterEditorView navigation from SettingsView
  - Prevention: Keep UI components modular and maintain clear navigation hierarchy

## Resolved Issues

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