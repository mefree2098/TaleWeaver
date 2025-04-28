import Foundation

enum Configuration {
    static var openAIAPIKey: String {
        // Get API key from UserDefaults
        return UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
    }
} 