import SwiftUI

struct CharacterRow: View {
    let character: Character
    
    var body: some View {
        HStack {
            if let avatarURL = character.avatarURL {
                AsyncImage(url: URL(string: avatarURL.hasPrefix("http") ? avatarURL : "file://\(avatarURL)")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .accessibilityLabel("Character avatar")
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .accessibilityLabel("Default character avatar")
            }
            
            VStack(alignment: .leading) {
                Text(character.name ?? "")
                    .font(.headline)
                    .accessibilityLabel("Character name")
                
                if let description = character.characterDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .accessibilityLabel("Character description")
                }
            }
        }
        .padding(.vertical, 8)
    }
} 