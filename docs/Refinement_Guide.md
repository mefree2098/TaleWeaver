# TaleWeaver Refinement Guide

This guide explains **exactly** how to move the existing TaleWeaver code-base from its current “feature-complete prototype” stage to a polished, production-ready iOS application that can be shipped on the App Store.  Every step is broken down into atomic tasks so that it can be executed by a junior developer or an LLM with limited reasoning capacity.

---
## Legend of task types

* 🛠  — Coding / implementation work
* 📐 — Design decision / ADR to be written
* ✅ — Verification / testing step
* 📚 — Documentation step
* 🎨 — Visual or UX polish
* 🚀 — Deployment / release activity

For each phase, perform the tasks **in order**.  Each task contains **Inputs**, **Action**, **Output** and **Commit message template** so that progress can be tracked via conventional commits.

---
## Phase 0 – Project preparation

1. 📚 **Clone & set up local environment**  
   • Inputs : Git repo URL, macOS with Xcode 15+, iOS 17 SDK  
   • Action : `git clone`, open `TaleWeaver.xcodeproj`, select _Any iOS Device_ target, run `⌘+R` and ensure the app builds  
   • Output : App launches on simulator showing Story List  
   • Commit : *none* (environment-only)

2. 📚 **Create new branch `refinement/<initials>/phase0`**  
   • Action : `git checkout -b refinement/jd/phase0`  
   • Output : Branch pushed  
   • Commit : *none*

3. 📚 **Audit pending warnings & TODOs**  
   • Action : Build → Product > Analyze, list warnings in `docs/Warnings_<date>.md`  
   • Output : File committed  
   • Commit : `docs: add static analyser warning list`

---
## Phase 1 – Data-layer hardening

### 1.1 Fix Core Data inverse relationship warnings

A. 🛠 Locate offending entities  
   • Inputs : Xcode > Data Model inspector shows yellow triangles for Story.prompts, StoryPrompt.story  
B. Action : Open `TaleWeaver.xcdatamodeld`, set inverse relationships correctly, choose *Nullify* delete rule  
C. Output : Build produces **no** Core Data warnings  
D. Commit : `coredata: add inverse relationships for Story<->StoryPrompt`

### 1.2 Add lightweight migration support

A. 🛠 Edit `PersistenceController.swift`  
   • Set `NSPersistentContainer(name: "TaleWeaver")` with `options:[.migratePersistentStoresAutomatically:true, . inferMappingModelAutomatically:true]`  
B. ✅ Delete the app → reinstall → verify data migrates  
C. Commit : `coredata: enable lightweight migration`

### 1.3 Unit tests for migrations

A. 🛠 Create `TaleWeaverTests/CoreDataMigrationTests.swift`  
B. Action : Write test loading a *v1* sqlite bundled in test resources; assert fetch request succeeds post-migration  
C. ✅ `⌘+U` green  
D. Commit : `test(coredata): cover lightweight migration path`

---
## Phase 2 – Template Engine completion

### 2.1 Schema & ADR

1. 📐 Write ADR 002 “Template Engine v1” in `docs/adr/ADR-002-Template_Engine_v1.md` describing token syntax `{{character.name}}`, markdown output etc.  
   • Commit : `adr: document template engine v1`

### 2.2 Core Data integration

1. 🛠 Add missing attributes to `StoryTemplate` (e.g. `placeholders: [String]`)  
2. 🛠 Generate NSManagedObject subclasses (manual)  
3. Commit : `coredata(template): add placeholders attr`

### 2.3 Parsing library

1. 🛠 Create new file `TemplateRenderer.swift` (pure Swift) implementing:  
   ```swift
   func render(template: String, context: [String:String]) -> String
   ```
   using regex `\{{2}(.*?)\}{2}`  
2. ✅ Add unit tests in `TemplateRendererTests.swift`  
3. Commit : `feat(template): add placeholder renderer`

### 2.4 ViewModel wiring

1. 🛠 Extend `TemplateViewModel` with `generatePrompt(for story:)`  
2. 🛠 Inject into `StoryEditorView` so Save uses renderer  
3. ✅ Manual test: create story from template, verify placeholders replaced  
4. Commit : `feat(template): connect renderer to story editor`

### 2.5 UI polish

1. 🎨 Update `TemplateSelectionView` to use `@FetchRequest` and show subtitle preview (first 50 chars)  
2. Commit : `ui(template): bind selection view to core data`

---
## Phase 3 – API robustness & caching

### 3.1 Exponential back-off queue for OpenAI

1. 🛠 Create `OpenAIQueue.swift` implementing a singleton `func enqueue(_ request: OpenAIRequest)` with retry + Jitter  
2. 🛠 Refactor `OpenAIService` calls to go through queue  
3. ✅ Unit test with mock server returning HTTP 429  
4. Commit : `feat(api): add back-off queue`

### 3.2 Avatar generation deduplication

1. 🛠 In `OpenAIService`, keep `inFlight[UUID:Task]` dictionary  
2. ✅ Test parallel avatar requests for same characterId only hit API once  
3. Commit : `perf(api): de-duplicate avatar generates`

---
## Phase 4 – UX & accessibility polish

1. 🎨 Add haptic feedback calls via `FeedbackManager` on: story saved, avatar generated, character deleted  
   • Commit : `ux: add haptics for key actions`

2. 🎨 Implement swift-UI animations:  
   • StoryCard scale on tap  
   • Chat message slide-in  
   • Commit : `ui: add card & chat animations`

3. 🎨 Add swipe-to-delete on character rows using `.onDelete`  
   • Commit : `ux: enable swipe delete on characters`

4. 🎨 Accessibility  
   • Add `.accessibilityLabel` for buttons, images  
   • Enable Dynamic Type via `font(.body)` not fixed sizes  
   • Commit : `a11y: label controls & dynamic type`

---
## Phase 5 – Testing & CI

1. 🛠 Add XCTest target `TaleWeaverUITests` with EarlGrey/XCUITests covering:  
   • Story creation via template  
   • Assign user character  
   • Avatar generation  
   • Delete character  
   • Commit : `test(ui): initial happy path tests`

2. 🛠 Set up GitHub Actions workflow `.github/workflows/ci.yml` running `xcodebuild -scheme TaleWeaver -destination "platform=iOS Simulator,name=iPhone 15" test`  
   • Commit : `ci: add github actions`

3. ✅ Push branch → ensure CI passes.

---
## Phase 6 – Performance & memory

1. 🛠 Use Instruments > Leaks, Time Profile; capture baseline, add findings to `docs/Performance_Report_<date>.md`  
   • Commit : `docs: initial perf report`

2. 🛠 Optimize slow spots (identified above) such as large avatar images in memory; implement `ImageCache` eviction policy  
   • Commit : `perf(image): LRU eviction`

---
## Phase 7 – Documentation finalisation

1. 📚 Update `Project_Structure.md` to reflect new files (TemplateRenderer, OpenAIQueue)  
2. 📚 Update `Deployment_Guide.md` with TestFlight & App Store submission instructions  
3. 📚 Fill CHANGELOG.md (create if missing) starting with `## [1.0.0] - YYYY-MM-DD`  
4. 📚 Mark ADR-001 status **Accepted**, ADR-002 **Accepted**  
5. Commit : `docs: final docs for v1`

---
## Phase 8 – Release

1. 🚀 Tag `v1.0.0` on `main`, push  
   • `git tag -a v1.0.0 -m "First stable release" && git push --tags`
2. 🚀 Archive in Xcode → Validate → Distribute via App Store Connect  
3. 🚀 Fill App Store metadata, upload screenshots  
4. 🚀 Submit for review

---
## Phase 9 – Post-release tasks

1. 📚 Create `docs/Post_Release_Report_<version>.md` with metrics (downloads, crashes)  
2. 🛠 Open issues for hotfixes  
3. 🎨 Plan v1.1 roadmap (cloud sync, collaboration) in project board.

---

### Completion criteria

The app is considered **Refined & Finished** when:
1. Test suite is green in CI
2. No Xcode warnings / Core Data issues
3. All checklist items in Script_Adherence are ✅
4. App passes App Store review & is available for download
5. Documentation is up-to-date and ADRs accepted.
