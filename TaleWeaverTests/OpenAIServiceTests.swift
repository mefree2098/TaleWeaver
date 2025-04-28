import XCTest
@testable import TaleWeaver

class OpenAIServiceTests: XCTestCase {
    var service: OpenAIService!
    
    override func setUp() {
        super.setUp()
        service = OpenAIService(apiKey: Secrets.openAIKey)
    }
    
    override func tearDown() {
        service = nil
        super.tearDown()
    }
    
    func testGenerateStory() async throws {
        let prompt = "A story about a magical forest"
        let story = try await service.generateStory(prompt: prompt)
        
        XCTAssertNotNil(story)
        XCTAssertFalse(story.isEmpty)
    }
    
    func testRateLimitHandling() async {
        // Simulate rate limit by making multiple rapid requests
        let prompt = "Test prompt"
        var rateLimitHit = false
        
        for _ in 0...5 {
            do {
                _ = try await service.generateStory(prompt: prompt)
            } catch OpenAIError.rateLimitExceeded {
                rateLimitHit = true
                break
            } catch {
                continue
            }
        }
        
        XCTAssertTrue(rateLimitHit, "Rate limit should be hit after multiple rapid requests")
    }
} 