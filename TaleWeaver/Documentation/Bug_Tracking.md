# Bug Tracking

## Test Coverage
- [x] StoryManager
- [x] ImageCache
- [x] StoryRepository
- [x] StoryViewModel
- [x] UI Components

## Known Issues

### Active Issues

#### View Initialization
- **Status**: Active
- **Issue**: App is currently using StartView as the main view, while ContentView is set up to use StoryListView. Need to decide which view to use as the main entry point.
- **Solution**: Pending decision on main view architecture
- **Prevention**: Document view hierarchy and navigation flow

#### CharacterViewModel Ambiguity
- **Status**: Resolved
- **Issue**: Duplicate implementation of CharacterViewModel in CharacterCustomizationView.swift
- **Solution**: Removed duplicate implementation and updated CharacterCustomizationView to use the centralized CharacterViewModel from ViewModels/CharacterViewModel.swift
- **Prevention**: Follow MVVM pattern strictly, keep view models in dedicated files

#### Character-Story Relationship
- **Status**: Resolved
- **Issue**: CharacterViewModel trying to access non-existent story property on Character entity
- **Solution**: Removed addCharacterToStory and removeCharacterFromStory methods as they were trying to access a property that doesn't exist in the current Core Data model
- **Prevention**: Ensure Core Data model properties are properly defined before implementing related functionality

#### CharacterManager Initialization
- **Status**: Resolved
- **Issue**: CharacterManager using 'this' instead of 'self' for instance property access
- **Solution**: Replaced 'this.context' with 'self.context' in the initializer
- **Prevention**: Use proper Swift syntax for instance property access

#### Character Entity Properties
- **Status**: Resolved
- **Issue**: CharacterCustomizationView trying to access non-existent properties on Character entity (personality, background, goals, relationships, avatar)
- **Solution**: Updated CharacterCustomizationView to match the actual Character entity properties in the Core Data model
- **Prevention**: Always check the Core Data model before accessing entity properties

#### ImagePicker Ambiguity
- **Status**: Resolved
- **Issue**: Duplicate ImagePicker implementation causing ambiguity errors
- **Solution**: Created a separate CharacterImagePicker.swift file in the Components directory and removed duplicate implementations from CharacterCustomizationView and CharacterEditorView
- **Prevention**: Keep reusable UI components in dedicated files in the Components directory

#### Redundant Underscore
- **Status**: Resolved
- **Issue**: Using '_' to ignore the result of a Void-returning function is redundant
- **Solution**: Removed the redundant underscore in CharacterEditorView
- **Prevention**: Avoid using underscore for void-returning functions

#### Complex Expression in CharacterDetailView
- **Status**: Resolved
- **Issue**: The compiler is unable to type-check a complex expression in CharacterDetailView
- **Solution**: Broke up the complex expression into smaller, more manageable parts by extracting the Stories section and Story row into separate view components
- **Prevention**: Keep view hierarchies simple and modular, extract complex UI components into separate views

#### Missing ViewModel Parameter
- **Status**: Resolved
- **Issue**: StoryDetailView was being called without the required viewModel parameter in CharacterDetailView
- **Solution**: Updated the StoryRow component to accept and pass the viewModel parameter to StoryDetailView
- **Prevention**: Always check required parameters when calling views, especially when navigating between views

#### Private Context Access
- **Status**: Resolved
- **Issue**: Attempting to access private context property from CharacterViewModel
- **Solution**: Used story.managedObjectContext instead of trying to access the private context
- **Prevention**: Respect access control levels and use appropriate context sources

#### OpenAIService Initialization
- **Status**: Resolved
- **Issue**: Missing required apiKey parameter in OpenAIService initialization
- **Solution**: Added apiKey parameter using environment variables with fallback
- **Prevention**: Always check required parameters for service initializations

### Resolved Issues

#### Optional Property Handling
- **Status**: Resolved
- **Issue**: Core Data optional properties causing build errors
- **Solution**: Added nil coalescing operators for all optional properties
- **Prevention**: Always handle Core Data optionals with nil coalescing

#### Missing Imports
- **Status**: Resolved
- **Issue**: Missing Core Data import in UI files
- **Solution**: Added import CoreData to all relevant files
- **Prevention**: Add Core Data import when working with Core Data entities

#### Image Caching
- **Status**: Resolved
- **Issue**: Memory leaks in ImageCache
- **Solution**: Implemented proper cache cleanup and memory management
- **Prevention**: Regular memory usage monitoring

#### Core Data Relationships
- **Status**: Resolved
- **Issue**: Incorrect relationship configuration in Core Data model
- **Solution**: Updated relationship settings and inverse relationships
- **Prevention**: Document Core Data model relationships

### StoryViewModel Initialization
- **Status**: Resolved
- **Issue**: StoryViewModel was being initialized with just a context parameter, but it requires both a repository and openAIService.
- **Solution**: Updated StoryRow to properly initialize StoryViewModel with both required dependencies.
- **Prevention**: Always check the required initialization parameters for view models and ensure all dependencies are properly injected.

## Best Practices

### Core Data
1. Always handle optional properties with nil coalescing
2. Keep view models in dedicated files
3. Use proper Core Data import statements
4. Document Core Data model relationships
5. Implement proper error handling for Core Data operations

### Memory Management
1. Monitor memory usage regularly
2. Implement proper cleanup for caches
3. Use weak references where appropriate
4. Handle image data efficiently

### Documentation
1. Keep bug tracking document updated
2. Document all resolved issues
3. Include prevention strategies
4. Update test coverage status

### Naming Conventions
1. Use clear, descriptive names
2. Follow Swift naming conventions
3. Maintain consistent naming across the project
4. Document naming conventions in project guidelines

### Core Data
1. Optional Property Handling
   - Status: ✅ Fixed
   - Issue: Core Data optional properties not properly handled in UI
   - Solution: Added nil coalescing operators for all optional properties
   - Prevention: Always handle optionals with default values

2. Missing Imports
   - Status: ✅ Fixed
   - Issue: Core Data import missing in UI files
   - Solution: Added import CoreData to all relevant files
   - Prevention: Add imports when using Core Data entities

3. Architecture Mismatch
   - Status: ✅ Fixed
   - Issue: ContentView using old architecture with viewModel while StoryListView uses direct Core Data
   - Solution: Updated ContentView to use Core Data environment
   - Prevention: Keep architecture consistent across views

4. Missing Parameters
   - Status: ✅ Fixed
   - Issue: Missing required parameters in StoryEditorView and StoryDetailView calls
   - Solution: Added viewModel to StoryListView and passed it to child views
   - Prevention: Always check parameter requirements when calling views

### Build Issues
1. Duplicate Files
   - Status: ✅ Fixed
   - Issue: Duplicate FeedbackManager.swift files causing build errors
   - Solution: Removed duplicate file from UI/Components, kept comprehensive version in Utilities
   - Prevention: Maintain clear file organization, avoid duplicates

2. Generic Type Constraints
   - Status: ✅ Fixed
   - Issue: customAnimation method using Any type that doesn't conform to Equatable
   - Solution: Updated method to use generic type T: Equatable
   - Prevention: Always check type constraints for SwiftUI methods

3. Complex Expressions
   - Status: ✅ Fixed
   - Issue: Compiler unable to type-check complex expressions in StoryListView
   - Solution: Broke up complex view into smaller, more manageable components
   - Prevention: Keep view hierarchies simple and modular

### UI Components
1. Card Animation Performance
   - Status: ✅ Fixed
   - Issue: Card animations causing performance issues
   - Solution: Optimized animation parameters and used LazyVStack
   - Prevention: Profile UI performance regularly

2. Haptic Feedback Timing
   - Status: ✅ Fixed
   - Issue: Haptic feedback not synchronized with animations
   - Solution: Added proper timing for haptic feedback
   - Prevention: Test haptic feedback with animations

3. Memory Management
   - Status: ✅ Fixed
   - Issue: Image caching causing memory growth
   - Solution: Implemented proper cache invalidation
   - Prevention: Monitor memory usage

### Accessibility
1. VoiceOver Support
   - Status: ✅ Fixed
   - Issue: Missing accessibility labels
   - Solution: Added proper labels and hints
   - Prevention: Test with VoiceOver regularly

2. Dynamic Type
   - Status: ✅ Fixed
   - Issue: Text not scaling with system font size
   - Solution: Used system fonts and proper scaling
   - Prevention: Test with different text sizes

## Best Practices
1. Core Data
   - Always handle optionals
   - Use proper error handling
   - Implement proper relationships
   - Use appropriate fetch requests
   - Keep architecture consistent

2. UI Components
   - Use native SwiftUI components
   - Implement proper animations
   - Add haptic feedback
   - Ensure accessibility
   - Optimize performance
   - Check type constraints for SwiftUI methods
   - Keep view hierarchies simple and modular
   - Check parameter requirements when calling views

3. Testing
   - Write unit tests
   - Test edge cases
   - Profile performance
   - Test accessibility

4. Documentation
   - Keep documentation updated
   - Document known issues
   - Document solutions
   - Document prevention measures

5. Project Organization
   - Maintain clear file structure
   - Avoid duplicate files
   - Keep related files together
   - Use appropriate directories 