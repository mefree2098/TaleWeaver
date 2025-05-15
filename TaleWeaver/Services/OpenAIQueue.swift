import Foundation

/// A queue for managing OpenAI API requests with exponential back-off and jitter on rate limit errors.
public actor OpenAIQueue {
    public static let shared = OpenAIQueue()
    
    /// Enqueues an asynchronous operation, retrying on rate limit errors with exponential back-off and jitter.
    /// - Parameters:
    ///   - operation: A closure that performs the API call and returns a result.
    /// - Returns: The result of the operation.
    public func enqueue<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        let maxRetries = 3
        var attempt = 0
        while true {
            do {
                return try await operation()
            } catch let error as OpenAIError {
                if case .rateLimitExceeded = error, attempt < maxRetries {
                    // Calculate exponential back-off with jitter
                    let delay = pow(2.0, Double(attempt)) + Double.random(in: 0..<1)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    attempt += 1
                    continue
                }
                throw error
            } catch {
                throw error
            }
        }
    }
}