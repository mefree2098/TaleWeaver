# ADR-002: Template Engine v1

## Status
Accepted

## Date
2025-05-15

## Context
The app offers story templates as Core Data objects (`StoryTemplate`) with a `promptTemplate` string containing tokens/placeholders (e.g. `{{character.name}}`). Currently, there is no formal parsing or rendering mechanism. We need a first‐generation Template Engine to let users select a template, fill in dynamic content, and generate story prompts.

## Decision
Implement a simple placeholder-based renderer that:

- Uses double curly braces `{{ }}` to denote placeholders
- Extracts placeholder keys via regex `\{\{(.*?)\}\}`
- Maps keys from a flat `[String: String]` context dictionary (e.g. `"character.name": "Aria"`)
- Substitutes placeholders with corresponding values; unrecognized keys render as empty strings
- Returns a `String` result which can feed the OpenAI prompt engine

Integrate this into:

- Core Data: Add a `placeholders: [String]` derived attribute to `StoryTemplate` for UI previews
- TemplateRenderer.swift: script‐only class for rendering logic
- TemplateViewModel: new `func generatePrompt(template:StoryTemplate, context:)` API
- StoryEditorView: use `generatePrompt` before creating a `StoryPrompt` entity

## Consequences

- Positive
  - Enables user‐customizable story prompts
  - Keeps parsing logic decoupled from UI
  - Easily testable with unit tests

- Negative
  - Flat context may limit nested or complex templating
  - No support yet for conditionals or loops
  - No built‐in error reporting for missing keys

## Alternatives Considered

1. Integrate Mustache or similar third‐party templating library
   - Pros: Full feature set (loops, conditionals)
   - Cons: Heavy dependency, learning curve, potential increased bundle size

2. Use Swift’s `NSExpression` to evaluate keypaths
   - Pros: Native APIs
   - Cons: Overkill for simple placeholder substitution, complexity in passing context

## References
- https://en.wikipedia.org/wiki/Mustache_(template_system)
- https://developer.apple.com/documentation/foundation/nsexpression
