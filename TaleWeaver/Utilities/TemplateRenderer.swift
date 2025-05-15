
import Foundation

/// A simple template renderer that replaces placeholders in the form `{{key}}` with values from a context dictionary.
public struct TemplateRenderer {
    /// Renders the given template string by replacing all `{{key}}` tokens with their corresponding values from the context.
    /// - Parameters:
    ///   - template: The template string containing placeholders like `{{key}}`.
    ///   - context: A dictionary mapping placeholder keys to replacement strings.
    /// - Returns: The rendered string with all placeholders replaced. Unrecognized keys render as empty strings.
    public static func render(template: String, context: [String: String]) -> String {
        do {
            let pattern = "\\{\\{(.*?)\\}\\}"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsString = template as NSString
            let range = NSRange(location: 0, length: nsString.length)
            var result = template
            // Find matches from end to avoid invalidating ranges
            let matches = regex.matches(in: template, options: [], range: range)
            for match in matches.reversed() {
                let keyRange = match.range(at: 1)
                let key = nsString.substring(with: keyRange).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = context[key] ?? ""
                let placeholderRange = match.range(at: 0)
                let start = result.index(result.startIndex, offsetBy: placeholderRange.location)
                let end = result.index(start, offsetBy: placeholderRange.length)
                result.replaceSubrange(start..<end, with: value)
            }
            return result
        } catch {
            return template
        }
    }
}
