import SwiftUI

/// Displays a single chat message with optional character avatar.
struct ChatMessageView: View {
    let prompt: StoryPrompt
    let userCharacter: Character?

    var body: some View {
        HStack(alignment: .top) {
            if let userCharacter = userCharacter,
               let avatarURL = userCharacter.avatarURL,
               !avatarURL.isEmpty,
               let url = URL(string: avatarURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(userCharacter.name?.prefix(1) ?? "U"))
                                .font(.headline)
                                .foregroundColor(.gray)
                        )
                }
            } else {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("U")
                            .font(.headline)
                            .foregroundColor(.blue)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(userCharacter?.name ?? "User")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(prompt.promptText ?? "")
                    .font(.body)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                Text(prompt.createdAt ?? Date(), style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Message from \(userCharacter?.name ?? "User"): \(prompt.promptText ?? "")")
    }
}

#Preview {
    let ctx = PersistenceController.preview.container.viewContext
    let story = Story(context: ctx)
    let prompt = StoryPrompt(context: ctx)
    prompt.promptText = "Hello world"
    prompt.createdAt = Date()
    return ChatMessageView(prompt: prompt, userCharacter: story.userCharacter)
        .environment(\.managedObjectContext, ctx)
}
