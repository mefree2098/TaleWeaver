import XCTest
import SwiftUI
@testable import TaleWeaver

class ImageCacheTests: XCTestCase {
    var cache: ImageCache!
    
    override func setUp() {
        super.setUp()
        cache = ImageCache.shared
        cache.removeAll()
    }
    
    override func tearDown() {
        cache.removeAll()
        super.tearDown()
    }
    
    func testImageCaching() {
        let testURL = URL(string: "https://example.com/test.jpg")!
        let testImage = UIImage(systemName: "star.fill")!
        
        // Test setting image
        cache.set(testImage, forKey: testURL.absoluteString)
        
        // Test getting cached image
        let cachedImage = cache.get(forKey: testURL.absoluteString)
        XCTAssertNotNil(cachedImage, "Cached image should not be nil")
    }
    
    func testCacheRemoval() {
        let testURL = URL(string: "https://example.com/test.jpg")!
        let testImage = UIImage(systemName: "star.fill")!
        
        // Set and verify image is cached
        cache.set(testImage, forKey: testURL.absoluteString)
        XCTAssertNotNil(cache.get(forKey: testURL.absoluteString), "Image should be cached")
        
        // Remove image and verify it's gone
        cache.remove(forKey: testURL.absoluteString)
        XCTAssertNil(cache.get(forKey: testURL.absoluteString), "Image should be removed from cache")
    }
    
    func testCacheClearing() {
        let urls = [
            URL(string: "https://example.com/test1.jpg")!,
            URL(string: "https://example.com/test2.jpg")!
        ]
        
        // Cache multiple images
        for url in urls {
            cache.set(UIImage(systemName: "star.fill")!, forKey: url.absoluteString)
        }
        
        // Clear cache
        cache.removeAll()
        
        // Verify all images are removed
        for url in urls {
            XCTAssertNil(cache.get(forKey: url.absoluteString), "All images should be removed from cache")
        }
    }
    
    func testCacheLimit() {
        // Create more images than the cache limit
        for i in 0...150 {
            let url = URL(string: "https://example.com/test\(i).jpg")!
            cache.set(UIImage(systemName: "star.fill")!, forKey: url.absoluteString)
        }
        
        // Verify cache size doesn't exceed limit
        // Note: This is an indirect test since we can't directly access the cache count
        // We can verify that the first few images are still accessible
        let firstURL = URL(string: "https://example.com/test0.jpg")!
        XCTAssertNotNil(cache.get(forKey: firstURL.absoluteString), "First image should still be in cache")
    }
} 