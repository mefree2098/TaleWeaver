import Foundation

enum OpenAIError: Error {
    case invalidResponse
    case rateLimitExceeded(retryAfter: TimeInterval)
    case apiError(String)
    case invalidAPIKey
    case imageGenerationFailed
    case imageSaveFailed
    case httpError(Int)
}

class OpenAIService {
    static var shared = OpenAIService(apiKey: UserDefaults.standard.string(forKey: "openAIAPIKey") ?? "")
    /// Call after user updates key to re-initialise singleton
    static func configure(apiKey: String) {
        shared = OpenAIService(apiKey: apiKey)
        UserDefaults.standard.set(apiKey, forKey: "openAIAPIKey")
    }
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    private let session: URLSession
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
        self.fileManager = FileManager.default
    }
    
    // MARK: - Text Generation

    /// Generic text generation helper
    /// - Parameter prompt: User prompt / instructions
    /// - Returns: Generated text from the model
    func generateStory(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIError.invalidAPIKey }

        let endpoint = "\(baseURL)/responses"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "model": "o4-mini",
            "input": prompt
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return try await OpenAIQueue.shared.enqueue { [self] in
            try await performTextRequest(request)
        }
    }

    /// Dedicated wrapper for generating a scene description.
    func generateSceneDescription(theme: String) async throws -> String {
        let fullPrompt = "Generate a vivid scene description: \(theme)"
        return try await generateStory(prompt: fullPrompt)
    }
    
    func generateCharacterAvatar(description: String, characterId: String, forceRegenerate: Bool = false) async throws -> String {
        print("🎨 Starting character avatar generation for characterId: \(characterId)")
        print("📝 Description: \(description)")
        
        guard !apiKey.isEmpty else {
            print("❌ Error: API key is empty")
            throw OpenAIError.invalidAPIKey
        }
        
        // Check if we already have an image for this character
        if !forceRegenerate {
            if let existingPath = try? getExistingImagePath(for: characterId) {
                print("♻️ Using existing image for character \(characterId)")
                print("📍 Image path: \(existingPath)")
                return existingPath
            }
        }
        
        print("🔄 Generating new image...")
        let prompt = "Create a detailed portrait of a character with the following description: \(description). The image should be a high-quality, professional character portrait."
        
        let requestBody: [String: Any] = [
            "model": "gpt-image-1",
            "prompt": prompt,
            "n": 1,
            "size": "1024x1024"
        ]
        
        print("📤 Sending request to OpenAI API...")
        print("🔍 Request details:")
        print("  - Model: gpt-image-1")
        print("  - Size: 1024x1024")
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/images/generations")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("⏳ Waiting for OpenAI response...")
        // Send via OpenAIQueue for exponential back-off on rate limits
        return try await OpenAIQueue.shared.enqueue { [self] in
            try await self.performImageRequest(request, characterId: characterId)
        }
    }
    
    private func getExistingImagePath(for characterId: String) throws -> String? {
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let avatarsDirectory = documentsDirectory.appendingPathComponent("character_avatars")
        let imagePath = avatarsDirectory.appendingPathComponent("\(characterId).png")
        print("🔍 Checking for existing image at: \(imagePath.path)")
        return fileManager.fileExists(atPath: imagePath.path) ? imagePath.path : nil
    }
    
    private func downloadAndSaveImage(from urlString: String, characterId: String) async throws -> String {
        print("📥 Starting image download from: \(urlString)")
        guard let url = URL(string: urlString) else {
            print("❌ Error: Invalid image URL")
            throw OpenAIError.apiError("Invalid image URL")
        }
        
        let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let avatarsDirectory = documentsDirectory.appendingPathComponent("character_avatars")
        let fileURL = avatarsDirectory.appendingPathComponent("\(characterId).png")
        
        print("📁 Creating avatars directory if needed...")
        try fileManager.createDirectory(at: avatarsDirectory, withIntermediateDirectories: true)
        
        print("⬇️ Downloading image data...")
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Error: Invalid response type")
            throw OpenAIError.invalidResponse
        }
        
        print("📡 Response status code: \(httpResponse.statusCode)")
        print("📡 Response headers: \(httpResponse.allHeaderFields)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Error: HTTP status code \(httpResponse.statusCode)")
            if let errorText = String(data: data, encoding: .utf8) {
                print("📄 Error response: \(errorText)")
            }
            throw OpenAIError.invalidResponse
        }
        
        print("💾 Saving image to: \(fileURL.path)")
        try data.write(to: fileURL)
        print("✅ Image saved successfully")
        
        return fileURL.path
    }
    
    func deleteCharacterAvatar(characterId: String) throws {
        if let imagePath = try getExistingImagePath(for: characterId) {
            try fileManager.removeItem(atPath: imagePath)
            print("Deleted image for character \(characterId)")
        }
    }
    
    // MARK: - New Responses API decoding
    private struct ResponsesEnvelope: Codable {
        let output_text: String
    }
    private struct OutputBlock: Codable {
        struct Content: Codable { let text: String? }
        let content: [Content]?
    }
    private struct GenericEnvelope: Codable { let output: [OutputBlock] }

    private func parseOutputArray(_ data: Data) throws -> String {
        let generic = try decoder.decode(GenericEnvelope.self, from: data)
        let texts = generic.output
            .flatMap { ($0.content ?? []).compactMap { $0.text } }
        guard !texts.isEmpty else { throw OpenAIError.invalidResponse }
        return texts.joined(separator: "\n")
    }

    private func performTextRequest(_ request: URLRequest) async throws -> String {
        var retryCount = 0
        let maxRetries = 3

        while true {
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { throw OpenAIError.invalidResponse }

                switch httpResponse.statusCode {
                case 200:
                    if let envelope = try? decoder.decode(ResponsesEnvelope.self, from: data) {
                        return envelope.output_text
                    } else if let fallbackText = try? parseOutputArray(data) {
                        return fallbackText
                    } else {
    #if DEBUG
                        if let raw = String(data: data, encoding: .utf8) {
                            print("[OpenAI] ⚠️ Unexpected 200 payload:\n\(raw)")
                        }
    #endif
                        throw OpenAIError.invalidResponse
                    }
                    
                case 401:
                    throw OpenAIError.invalidAPIKey
                    
                case 429:
                    if retryCount >= maxRetries {
                        throw OpenAIError.rateLimitExceeded(retryAfter: 60)
                    }
                    
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                        .flatMap { Double($0) } ?? 60.0
                    
                    try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                    retryCount += 1
                    continue
                    
                default:
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorJson["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        throw OpenAIError.apiError(message)
                    } else {
                        throw OpenAIError.apiError("HTTP \(httpResponse.statusCode)")
                    }
                }
            } catch {
                if retryCount >= maxRetries {
                    throw error
                }
                retryCount += 1
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
            }
        }
    }
    
    private func performImageRequest(_ request: URLRequest, characterId: String) async throws -> String {
        print("🚀 Performing image request...")
        var retryCount = 0
        let maxRetries = 3
        
        while true {
            do {
                print("📡 Sending request (attempt \(retryCount + 1)/\(maxRetries))...")
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Error: Invalid response type")
                    throw OpenAIError.invalidResponse
                }
                
                print("📡 Response status code: \(httpResponse.statusCode)")
                print("📡 Response headers: \(httpResponse.allHeaderFields)")
                
                if let responseText = String(data: data, encoding: .utf8) {
                    print("📄 Response body: \(responseText)")
                }
                
                switch httpResponse.statusCode {
                case 200:
                    let result = try decoder.decode(ImageResponse.self, from: data)
                    print("✅ Successfully decoded image response")
                    guard let imageData = result.data.first,
                          let imageBytes = Data(base64Encoded: imageData.b64_json) else {
                        throw OpenAIError.invalidResponse
                    }
                    
                    // Save the image to the character avatars directory
                    let fileManager = FileManager.default
                    let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let characterAvatarsPath = documentsPath.appendingPathComponent("character_avatars")
                    
                    // Create the directory if it doesn't exist
                    try? fileManager.createDirectory(at: characterAvatarsPath, withIntermediateDirectories: true)
                    
                    let imagePath = characterAvatarsPath.appendingPathComponent("\(characterId).png")
                    try imageBytes.write(to: imagePath)
                    return imagePath.path
                    
                case 401:
                    print("❌ Error: Invalid API key")
                    throw OpenAIError.invalidAPIKey
                    
                case 429:
                    if retryCount >= maxRetries {
                        print("❌ Error: Rate limit exceeded after \(maxRetries) retries")
                        throw OpenAIError.rateLimitExceeded(retryAfter: 60)
                    }
                    
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                        .flatMap { Double($0) } ?? 60.0
                    print("⏳ Rate limited. Waiting \(retryAfter) seconds before retry...")
                    
                    try await Task.sleep(nanoseconds: UInt64(retryAfter * 1_000_000_000))
                    retryCount += 1
                    continue
                    
                default:
                    if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = errorJson["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        print("❌ Error from OpenAI: \(message)")
                        throw OpenAIError.apiError(message)
                    } else {
                        print("❌ Error: HTTP \(httpResponse.statusCode)")
                        throw OpenAIError.apiError("HTTP \(httpResponse.statusCode)")
                    }
                }
            } catch {
                print("❌ Request error: \(error)")
                if retryCount >= maxRetries {
                    throw error
                }
                retryCount += 1
                let delay = pow(2.0, Double(retryCount))
                print("⏳ Retrying in \(delay) seconds...")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}

struct ImageResponse: Codable {
    let data: [ImageData]
    let usage: Usage
}

struct ImageData: Codable {
    let b64_json: String
}

struct Usage: Codable {
    let input_tokens: Int
    let output_tokens: Int
    let total_tokens: Int
    let input_tokens_details: TokenDetails
}

struct TokenDetails: Codable {
    let image_tokens: Int
    let text_tokens: Int
} 
