import SwiftUI

enum Theme {

    // MARK: - Backgrounds (3-tier depth system)

    static let background = Color(hex: 0x0B0E14)
    static let surface = Color(hex: 0x12161F)
    static let elevated = Color(hex: 0x1A1F2E)

    // MARK: - Accent (emerald/mint — primary actions, CTAs)

    static let accent = Color(hex: 0x34D399)
    static let accentDim = Color(hex: 0x34D399, opacity: 0.15)
    static let accentGlow = Color(hex: 0x34D399, opacity: 0.25)

    // MARK: - Gold (badges, streaks, premium ONLY)

    static let gold = Color(hex: 0xF5C542)
    static let goldDim = Color(hex: 0xF5C542, opacity: 0.12)

    // MARK: - Semantic

    static let success = Color(hex: 0x34D399)
    static let warning = Color(hex: 0xFBBF24)
    static let danger = Color(hex: 0xEF4444)

    // MARK: - Text (4-level hierarchy)

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textMuted = Color(hex: 0x4B5563)
    static let textDisabled = Color(hex: 0x374151)

    // MARK: - Borders & Dividers

    static let border = Color(hex: 0x1F2937)
    static let divider = Color(hex: 0x1F2937, opacity: 0.5)

    // MARK: - Glass Material

    static let glass = Color.white.opacity(0.05)
    static let glassBorder = Color.white.opacity(0.08)
    static let glassHighlight = Color.white.opacity(0.12)

    // MARK: - Legacy Aliases (backward-compatible)

    static let card = elevated
    static let cardSurface = elevated
    static let secondary = accent
    static let accentGreen = accent
    static let teal = accent
    static let emergency = danger
    static let tabBarBg = Color(hex: 0x0B0E14)
    static let unselectedTab = textMuted

    // MARK: - Gradients

    static let accentGradient = LinearGradient(
        colors: [Color(hex: 0x34D399), Color(hex: 0x059669)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let premiumGradient = LinearGradient(
        colors: [Color(hex: 0xF5C542), Color(hex: 0xD97706)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = premiumGradient

    static let successGradient = accentGradient

    static let meshBackground = MeshGradient(
        width: 3, height: 3,
        points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ],
        colors: [
            .black, Color(hex: 0x0B0E14), .black,
            Color(hex: 0x34D399).opacity(0.04), Color(hex: 0x0B0E14), Color(hex: 0x059669).opacity(0.03),
            .black, Color(hex: 0x34D399).opacity(0.03), .black
        ]
    )

    // MARK: - Typography

    static func headingFont(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

    static let numericSpring = Animation.spring(response: 0.4, dampingFraction: 0.8)

    static let amountXL: Font = .system(size: 48, weight: .bold, design: .rounded)
    static let amountLG: Font = .system(size: 34, weight: .bold, design: .rounded)

    // MARK: - Spacing

    enum Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 48
        static let xxxxl: CGFloat = 64
    }

    // MARK: - Corner Radii

    enum Radius {
        static let pill: CGFloat = 8
        static let button: CGFloat = 12
        static let card: CGFloat = 16
        static let modal: CGFloat = 20
    }

    // MARK: - Animation

    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let springSnappy = Animation.spring(response: 0.3, dampingFraction: 0.75)
    static let springStagger = Animation.spring(response: 0.5, dampingFraction: 0.75)
    static let colorTransition = Animation.easeOut(duration: 0.2)

    static func staggerDelay(_ index: Int) -> Animation {
        springStagger.delay(Double(index) * 0.08)
    }
}

// MARK: - Color Hex Init

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = Theme.Radius.card

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = Theme.Radius.card) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Button Styles

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: Theme.accent.opacity(configuration.isPressed ? 0 : 0.3), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
