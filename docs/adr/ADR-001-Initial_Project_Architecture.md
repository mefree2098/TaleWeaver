# ADR-001: Initial Project Architecture

## Status
Accepted

## Date
2025-05-15

## Context
We need a clear, consistent foundation for the TaleWeaver iOS application to support:

- AI-powered story generation and character image creation
- Persistence via Core Data
- MVVM architecture with SwiftUI
- Modular components, services, and testability

## Decision
Adopt the following architecture and technologies:

1. MVVM Pattern (Model–View–ViewModel) with SwiftUI  
2. Core Data as the primary persistence layer, manual code generation for entities  
3. Repository layer (e.g., `StoryRepository`) for data access abstractions  
4. Services layer for third-party integrations (OpenAI API)  
5. Utilities for shared functionality (ImageCache, FeedbackManager, URLUtils)  
6. Unit tests and UI tests integrated into CI  
7. Git Flow branching strategy (main, develop, feature/*, release/*, hotfix/*)

## Consequences

- Positive:
  - Clear separation of concerns  
  - Scalable codebase with testable components  
  - Reusable services and utilities  

- Negative:
  - Initial overhead to set up Core Data and repositories  
  - Potential complexity for junior developers unfamiliar with MVVM

## Alternatives Considered

- MVC with UIKit
  - Simpler for small projects, but less scalable for testability and separation of concerns  
- Third-party ORM (e.g., Realm)
  - Faster to iterate but adds an external dependency and complexity  

## References
- Apple documentation on MVVM and SwiftUI  
- Core Data best practices  
- https://martinfowler.com/bliki/Repository.html
