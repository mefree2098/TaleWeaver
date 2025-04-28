import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Maximum number of images to cache
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}

extension Image {
    init?(url: URL) {
        if let cached = ImageCache.shared.get(forKey: url.absoluteString) {
            self.init(uiImage: cached)
            return
        }
        
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
            return nil
        }
        
        ImageCache.shared.set(uiImage, forKey: url.absoluteString)
        self.init(uiImage: uiImage)
    }
} 