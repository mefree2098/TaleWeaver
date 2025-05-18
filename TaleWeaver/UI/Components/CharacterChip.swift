import SwiftUI

struct CharacterChip: View {
    let character: Character
    var removeAction: ((Character) -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            AsyncImage(url: URLUtils.createURL(from: character.avatarURL ?? "")) { phase in
                switch phase {
                case .empty:
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                case .success(let img):
                    img.resizable().scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                case .failure:
                    Circle().fill(Color.gray.opacity(0.3))
                        .overlay(Text(String(character.initials)).foregroundColor(.white))
                        .frame(width: 32, height: 32)
                @unknown default:
                    EmptyView()
                }
            }
            Text(character.name ?? "")
                .font(.subheadline)
                .lineLimit(1)
            if let remove = removeAction {
                Button(action: { remove(character) }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove character")
            }
        }
        .padding(6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

private extension Character {
    var initials: String {
        guard let n = name, !n.isEmpty else { return "?" }
        return String(n.prefix(1))
    }
}

#Preview {
    let ctx = PersistenceController.preview.container.viewContext
    let c = Character(context: ctx); c.name = "Alex"; c.avatarURL = ""
    return CharacterChip(character: c)
}