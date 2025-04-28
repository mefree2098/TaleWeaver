import SwiftUI

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Group {
                if let avatarURL = character.avatarURL {
                    AsyncImage(url: URLUtils.createURL(from: avatarURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        case .failure:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                }
            }
            .accessibilityLabel("Character avatar")
            
            // Character Info
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibilityLabel("Character name")
                
                if let description = character.characterDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .accessibilityLabel("Character description")
                }
            }
            
            Spacer()
            
            // Navigation Indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .semibold))
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let character = Character(context: context)
    character.name = "Preview Character"
    character.characterDescription = "This is a preview character description for testing purposes."
    character.avatarURL = "https://example.com/avatar.jpg"
    
    return CharacterRow(character: character)
        .padding()
} 