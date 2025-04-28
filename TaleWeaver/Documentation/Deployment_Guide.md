# TaleWeaver Deployment Guide

## Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- OpenAI API key

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/TaleWeaver.git
cd TaleWeaver
```

### 2. Configure OpenAI API Key
1. Open the project in Xcode
2. Run the app on a simulator or device
3. Go to Settings in the app
4. Enter your OpenAI API key

Alternatively, you can set the API key programmatically by modifying the `Configuration.swift` file:

```swift
enum Configuration {
    static var openAIAPIKey: String {
        // Replace with your actual API key
        return "your-api-key-here"
    }
}
```

### 3. Build and Run
1. Select your target device or simulator
2. Click the Run button (▶️) or press Cmd+R

## Project Structure
The project follows the MVVM architecture pattern:

- **Models**: Core Data entities for Story, StoryPrompt, and Character
- **Views**: SwiftUI views for displaying and interacting with data
- **ViewModels**: Classes that manage the business logic and data flow
- **Services**: Classes that handle external API communication
- **Repositories**: Classes that manage data persistence

## Core Data Setup
The app uses Core Data for persistence. The data model is defined in `TaleWeaver.xcdatamodeld` and includes:

- **Story**: Represents a story with title, content, and relationships
- **StoryPrompt**: Represents a prompt used to generate a story
- **Character**: Represents a character with name, description, and relationships

## Troubleshooting

### Common Issues

#### OpenAI API Key Not Working
- Ensure the API key is correctly entered in Settings
- Check that the API key has sufficient permissions
- Verify that the API key is not expired

#### Core Data Issues
- If you encounter Core Data errors, try deleting the app and reinstalling
- Check that the Core Data model version matches the app version

#### Build Errors
- Clean the build folder (Shift+Cmd+K)
- Clean the build cache (Option+Shift+Cmd+K)
- Restart Xcode

## Future Enhancements
- Template selection for story creation
- Improved character creation and customization
- Character-story relationship management
- Advanced story generation options
- Enhanced UI with more visual elements and animations 