# TaleWeaver Project Structure

## Overview
TaleWeaver is an iOS application built with SwiftUI, Combine, and Core Data for generating and managing AI-powered stories.

## Directory Structure
```
TaleWeaver/
├── TaleWeaver.xcodeproj/     # Xcode project files
├── TaleWeaver/              # Main application directory
│   ├── App/                 # App entry point and configuration
│   ├── Features/           # Feature modules
│   │   └── StartView.swift # Initial view for the app
│   ├── Core/              # Core functionality
│   │   └── PersistenceController.swift # Core Data management
│   ├── Models/           # Data models
│   │   └── TaleWeaver.xcdatamodeld/ # Core Data model
│   ├── Services/        # Business logic and services
│   ├── UI/             # Reusable UI components
│   └── Resources/     # Assets and resources
│       └── Assets.xcassets/ # App assets
└── docs/              # Documentation
    ├── Project_Structure.md
    ├── Bug_Tracking.md
    ├── Script_Adherence.md
    ├── Development_Workflow.md
    └── adr/          # Architecture Decision Records
```

## Component Relationships
- **App**: Entry point and app configuration (TaleWeaverApp.swift)
- **Features**: Individual feature modules (StartView.swift)
- **Core**: Shared functionality and utilities (PersistenceController.swift)
- **Models**: Data models and Core Data entities (TaleWeaver.xcdatamodeld)
- **Services**: Business logic, API clients, and data management
- **UI**: Reusable SwiftUI components and views
- **Resources**: Assets, localization, and configuration files

## Data Flow
1. User interactions trigger UI events in StartView
2. Events are processed by ViewModels (to be implemented)
3. ViewModels coordinate with Services (to be implemented)
4. Services manage data through Core Data via PersistenceController
5. UI updates reflect data changes

## Core Data Model
- **Story**: Entity representing a generated story
  - Attributes: id, title, content, createdAt, updatedAt
  - Relationships: prompts (to StoryPrompt)
- **StoryPrompt**: Entity representing a prompt for story generation
  - Attributes: id, title, promptText, createdAt
  - Relationships: story (to Story)

## Dependencies
- SwiftUI for UI framework
- Combine for reactive programming
- Core Data for persistence
- OpenAI API for story generation (to be implemented)

## Version Control
- Main branch: Production-ready code
- Develop branch: Integration branch
- Feature branches: Individual features
- Release branches: Version preparation 