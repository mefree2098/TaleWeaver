import Foundation
import CoreData

@objc(StoryTemplate)
public class StoryTemplate: NSManagedObject, Identifiable {
    /// Computed placeholder tokens parsed from `promptTemplate` (contents inside `{{ }}`)
    public var parsedPlaceholders: [String] {
        guard let template = promptTemplate else { return [] }
        do {
            let regex = try NSRegularExpression(pattern: "\\{\\{(.*?)\\}\\}", options: [])
            let range = NSRange(location: 0, length: template.utf16.count)
            let matches = regex.matches(in: template, options: [], range: range)
            return matches.compactMap { match in
                guard let range = Range(match.range(at: 1), in: template) else { return nil }
                return String(template[range])
            }
        } catch {
            return []
        }
    }
}