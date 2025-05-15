import XCTest
@testable import TaleWeaver

class OpenAIQueueTests: XCTestCase {
    struct DummyError: Error {}
    
    func testEnqueueSuccessDoesNotRetry() async throws {
        let result = try await OpenAIQueue.shared.enqueue {
            return "ok"
        }
        XCTAssertEqual(result, "ok")
    }
    
    func testEnqueueRateLimitRetries() async throws {
        var calls = 0
        let result = try await OpenAIQueue.shared.enqueue {
            calls += 1
            if calls < 3 {
                throw OpenAIError.rateLimitExceeded(retryAfter: 0)
            }
            return "done"
        }
        XCTAssertEqual(result, "done")
        XCTAssertEqual(calls, 3)
    }
    
    func testEnqueueNonRateLimitErrorPropagates() async throws {
        do {
            _ = try await OpenAIQueue.shared.enqueue {
                throw DummyError()
            }
            XCTFail("Expected DummyError to be thrown")
        } catch {
            XCTAssertTrue(error is DummyError)
        }
    }
}