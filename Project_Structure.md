## UI Components

### CharacterRow
- Location: `TaleWeaver/UI/CharacterRow.swift`
- Purpose: Displays a character's avatar and basic information in a list row
- Features:
  - Asynchronous image loading with loading state
  - Circular avatar with shadow
  - Character name and description display
  - Accessibility support
  - Navigation link support

### UserCharacterListView
- Location: `TaleWeaver/UI/SettingsView.swift`
- Purpose: Displays a list of user-created characters
- Features:
  - Core Data integration with @FetchRequest
  - Character deletion with confirmation
  - Navigation to character editor
  - Add new character button
  - Proper error handling 

## Data Management Patterns

### Core Data Integration
- Using SwiftUI's built-in Core Data integration with `@FetchRequest` and `@Environment(\.managedObjectContext)`
- This pattern is used for:
  - UserCharacterListView
  - Character management
  - Any other views that need direct Core Data access

### View Models
- Used for complex business logic and API interactions
- Examples:
  - CharacterViewModel for OpenAI API interactions
  - StoryViewModel for story generation 