import Foundation

struct StoryCharacter: Identifiable, Hashable {
    let id: UUID
    var name: String
    var role: String
    var description: String
    var imageURL: URL?
    var traits: [String]
    var background: String
    var relationships: [String: String]
    var goals: [String]
    var conflicts: [String]
    
    init(id: UUID = UUID(), 
         name: String, 
         role: String, 
         description: String, 
         imageURL: URL? = nil,
         traits: [String] = [],
         background: String = "",
         relationships: [String: String] = [:],
         goals: [String] = [],
         conflicts: [String] = []) {
        self.id = id
        self.name = name
        self.role = role
        self.description = description
        self.imageURL = imageURL
        self.traits = traits
        self.background = background
        self.relationships = relationships
        self.goals = goals
        self.conflicts = conflicts
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: StoryCharacter, rhs: StoryCharacter) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data
extension StoryCharacter {
    static var sampleCharacters: [StoryCharacter] {
        [
            StoryCharacter(
                name: "John Doe",
                role: "Protagonist",
                description: "A brave warrior with a mysterious past",
                traits: ["Brave", "Loyal", "Determined"],
                background: "Born in a small village, John left home at a young age to seek adventure.",
                relationships: ["Jane Smith": "Rival", "Bob Wilson": "Friend"],
                goals: ["Find the ancient artifact", "Protect the kingdom"],
                conflicts: ["Internal struggle with past", "Rivalry with Jane"]
            ),
            StoryCharacter(
                name: "Jane Smith",
                role: "Antagonist",
                description: "A cunning villain with a hidden agenda",
                traits: ["Cunning", "Ambitious", "Intelligent"],
                background: "Raised in the royal court, Jane learned to manipulate from an early age.",
                relationships: ["John Doe": "Rival", "Bob Wilson": "Enemy"],
                goals: ["Seize power", "Obtain the ancient artifact"],
                conflicts: ["Moral dilemma", "Trust issues"]
            ),
            StoryCharacter(
                name: "Bob Wilson",
                role: "Supporting",
                description: "A loyal friend who provides comic relief",
                traits: ["Loyal", "Funny", "Resourceful"],
                background: "A former merchant who joined the adventure for excitement.",
                relationships: ["John Doe": "Friend", "Jane Smith": "Enemy"],
                goals: ["Help John succeed", "Find true love"],
                conflicts: ["Fear of failure", "Family expectations"]
            )
        ]
    }
} 