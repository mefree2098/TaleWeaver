import SwiftUI

/// A custom view modifier that applies a consistent card style to story views
struct StoryCardModifier: ViewModifier {
    /// The pressed state of the card
    @State private var isPressed = false
    
    /// Apply the modifier to a view
    /// - Parameter content: The content to modify
    /// - Returns: The modified view
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .background(
                StoryCardShape()
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: isPressed ? 5 : 10,
                        x: 0,
                        y: isPressed ? 2 : 5
                    )
            )
            .overlay(
                StoryCardShape()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.2),
                                Color.purple.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                }
                
                // Provide haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
                // Reset the pressed state after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        isPressed = false
                    }
                }
            }
    }
}

/// Extension to make the modifier easier to use
extension View {
    /// Apply the story card style to a view
    /// - Returns: The modified view
    func storyCard() -> some View {
        modifier(StoryCardModifier())
    }
}

/// Preview provider for the story card modifier
struct StoryCardModifier_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Basic card
            VStack(alignment: .leading, spacing: 8) {
                Text("Story Title")
                    .font(.headline)
                Text("Story content preview...")
                    .font(.body)
                    .lineLimit(2)
            }
            .padding()
            .storyCard()
            
            // Card with image
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "book.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("Another Story")
                    .font(.headline)
                Text("More story content...")
                    .font(.body)
                    .lineLimit(2)
            }
            .padding()
            .storyCard()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 