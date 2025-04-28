import SwiftUI

/// A custom shape for story cards with a unique design
struct StoryCardShape: Shape {
    /// The corner radius for the card
    private let cornerRadius: CGFloat = 12
    
    /// The inset for the bottom right corner
    private let bottomRightInset: CGFloat = 8
    
    /// Create the path for the shape
    /// - Parameter rect: The rectangle to create the path in
    /// - Returns: The path for the shape
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Top left corner
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top right corner
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius - bottomRightInset))
        
        // Bottom right corner with inset
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius - bottomRightInset, y: rect.maxY),
            control: CGPoint(x: rect.maxX - bottomRightInset, y: rect.maxY)
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // Bottom left corner
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top left corner
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        
        return path
    }
}

/// Preview provider for the story card shape
struct StoryCardShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Basic shape
            StoryCardShape()
                .fill(Color.blue)
                .frame(width: 200, height: 100)
            
            // Shape with gradient
            StoryCardShape()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 100)
            
            // Shape with shadow
            StoryCardShape()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .frame(width: 200, height: 100)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 