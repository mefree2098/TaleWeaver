import Foundation

/// Utility functions for URL handling
enum URLUtils {
    /// Formats a URL string to ensure it's properly formatted for loading in AsyncImage
    /// - Parameter urlString: The URL string to format
    /// - Returns: A properly formatted URL string
    static func formatURL(_ urlString: String) -> String {
        // If it's already a fully qualified URL (http or https), return as is
        if urlString.hasPrefix("http://") || urlString.hasPrefix("https://") {
            return urlString
        }
        
        // If it's a local file path, ensure it has the file:// prefix
        if !urlString.hasPrefix("file://") {
            return "file://\(urlString)"
        }
        
        return urlString
    }
    
    /// Creates a URL from a string, ensuring it's properly formatted
    /// - Parameter urlString: The URL string to convert
    /// - Returns: A URL object, or nil if the string is invalid
    static func createURL(from urlString: String) -> URL? {
        let formattedURL = formatURL(urlString)
        return URL(string: formattedURL)
    }
} 