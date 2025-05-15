import Foundation
import CoreData

extension StoryTemplate {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryTemplate> {
        return NSFetchRequest<StoryTemplate>(entityName: "StoryTemplate")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var templateDescription: String?
    @NSManaged public var promptTemplate: String?
    @NSManaged public var placeholders: [String]?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var stories: NSSet?
}

// MARK: Generated accessors for stories
extension StoryTemplate {
    @objc(addStoriesObject:)
    @NSManaged public func addToStories(_ value: Story)

    @objc(removeStoriesObject:)
    @NSManaged public func removeFromStories(_ value: Story)

    @objc(addStories:)
    @NSManaged public func addToStories(_ values: NSSet)

    @objc(removeStories:)
    @NSManaged public func removeFromStories(_ values: NSSet)
} 