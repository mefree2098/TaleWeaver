import Foundation

enum Secrets {
    static var openAIKey: String {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API key not found in environment variables")
        }
        return key
    }
} 