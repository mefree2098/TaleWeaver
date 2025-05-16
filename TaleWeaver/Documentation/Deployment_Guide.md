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
2. Go to **Settings** tab in the running app
3. Paste your OpenAI API key

Alternatively, for automation (CI or environment variables), set a build setting in Xcode:
1. Select the **TaleWeaver** target → **Build Settings**
2. Add User-Defined setting `OPENAI_API_KEY = your-api-key-here`
3. In `Configuration.swift`, read `ProcessInfo.processInfo.environment["OPENAI_API_KEY"]`

### 3. Build and Run
1. Select your target device or simulator
2. Click the Run button (▶️) or press Cmd+R

## TestFlight & App Store Distribution

### Create an Archive
1. In Xcode, Product → Archive (select **Any iOS Device**)
2. Once archived, the **Organizer** window opens

### Validate & Upload
1. Click **Validate App** and fix any issues
2. Click **Distribute App** → **App Store Connect** → **Upload**
3. Follow the steps to upload your build

### App Store Connect
1. Log in to App Store Connect
2. Create a new app record (if first release) or select existing
3. Under **App Information**, fill in title, description, keywords, support URL
4. Upload localized screenshots (iPhone 15, 15 Pro, etc.)
5. Select the build you just uploaded and start the release process

## CI Integration
- GitHub Actions: `.github/workflows/ci.yml` runs lint, unit, and UI tests on each push/PR
- Fastlane (optional): configure `Fastfile` for beta deployments

## Rollback & Hotfixes
1. Create a `hotfix/x.y.z` branch from `main`
2. Apply fix, bump version in `Configuration.swift` and `CHANGELOG.md`
3. Run CI, merge back to `main` and `develop`, tag release

## Troubleshooting

### Build Failures
- Clean Derived Data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
- Clean Build Folder: Product → Clean Build Folder (⌥+⇧+⌘+K)
- Ensure Core Data model is in sync with generated code

### Crashes on Launch
- Verify Core Data migration settings (`NSMigratePersistentStoresAutomatically`, `NSInferMappingModelAutomatically`)
- Delete and reinstall the app

### Networking Issues
- Verify API key in Settings or environment
- Check network connectivity

## Versioning
Follow [Semantic Versioning 2.0.0](https://semver.org/): MAJOR.MINOR.PATCH

## Future Enhancements
- Cloud sync with CloudKit
- Beta rollouts via TestFlight groups
- Automated screenshot capture with `snapshot` or `fastlane screengrab`
