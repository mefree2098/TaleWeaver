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
- Status: In Progress
- Description: Limited functionality for managing relationships between characters and stories
- Impact: Users cannot easily track which characters appear in which stories
- Priority: Medium

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
- Description: Three build errors related to template integration
- Solution: 
  1. Removed access to non-existent template property
  2. Fixed conditional binding for non-optional String
  3. Removed template parameter from createStory method
- Prevention: Ensure proper Core Data model setup before implementing UI features

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