import SwiftUI
import CoreHaptics

/// Utility class for managing haptic feedback and animations
class FeedbackManager {
    /// Singleton instance
    static let shared = FeedbackManager()
    
    /// Haptic engine for custom haptics
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    /// Prepare the haptic engine
    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptics error: \(error.localizedDescription)")
        }
    }
    
    /// Play a simple haptic feedback
    func playSimpleFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Play a notification haptic feedback
    func playNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// Play a selection haptic feedback
    func playSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Play a custom haptic pattern
    func playCustomHaptic(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine = engine else { return }
        
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic: \(error.localizedDescription)")
        }
    }
}

/// Extension for common animations
extension Animation {
    /// Spring animation with custom parameters
    static func springAnimation(response: Double = 0.5, dampingFraction: Double = 0.7, blendDuration: Double = 0) -> Animation {
        .spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
    }
    
    /// Bounce animation
    static func bounceAnimation() -> Animation {
        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    }
    
    /// Fade animation
    static func fadeAnimation(duration: Double = 0.3) -> Animation {
        .easeInOut(duration: duration)
    }
}

/// Extension for common view modifiers
extension View {
    /// Add a shadow with custom parameters
    func customShadow(color: Color = .black, radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 5) -> some View {
        self.shadow(color: color.opacity(0.2), radius: radius, x: x, y: y)
    }
    
    /// Add a blur effect with custom parameters
    func customBlur(radius: CGFloat = 10, opacity: Double = 0.5) -> some View {
        self.blur(radius: radius)
            .opacity(opacity)
    }
    
    /// Add a gradient background
    func gradientBackground(colors: [Color] = [.blue, .purple], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.background(
            LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)
        )
    }
    
    /// Add a custom animation with a value that conforms to Equatable
    func customAnimation<T: Equatable>(_ animation: Animation = .springAnimation(), value: T) -> some View {
        self.animation(animation, value: value)
    }
} 