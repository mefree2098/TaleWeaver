import Foundation

enum OpenAIError: Error {
    case invalidResponse
    case rateLimitExceeded(retryAfter: TimeInterval)
    case apiError(String)
    case invalidAPIKey
}

class OpenAIService {
    static let shared = OpenAIService(apiKey: UserDefaults.standard.string(forKey: "openAIAPIKey") ?? "")
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(apiKey: String) {
        self.apiKey = apiKey
        self.session = URLSession.shared
        self.decoder = JSONDecoder()
    }
    
    func generateStory(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let endpoint = "\(baseURL)/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a creative storyteller."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return try await performRequest(request)
    }
    
    func generateCharacterAvatar(description: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        let endpoint = "\(baseURL)/images/generations"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "dall-e-3",
            "prompt": "Create a full-body portrait of a character with the following description: \(description). Style: digital art, clean lines, vibrant colors, full body shot from head to toe, centered composition.",
            "n": 1,
            "size": "1024x1024"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return try await performImageRequest(request)
    }
    
    private func performRequest(_ request: URLRequest) async throws -> String {
        var retryCount = 0
        let maxRetries = 3
        
        while true {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw OpenAIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    let result = try decoder.decode(OpenAIResponse.self, from: data)
                    return result.choices.first?.message.content ?? ""
                    
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
    
    private func performImageRequest(_ request: URLRequest) async throws -> String {
        var retryCount = 0
        let maxRetries = 3
        
        while true {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw OpenAIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    let result = try decoder.decode(ImageResponse.self, from: data)
                    return result.data.first?.url ?? ""
                    
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
}

struct ImageData: Codable {
    let url: String
} 