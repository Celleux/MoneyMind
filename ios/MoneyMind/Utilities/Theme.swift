import SwiftUI

enum Theme {

    // MARK: - Backgrounds (OLED-optimized dark)

    static let background = Color(hex: 0x0A0F1E)
    static let card = Color(hex: 0x111827)
    static let elevated = Color(hex: 0x1A2236)

    // MARK: - Accents

    static let accent = Color(hex: 0x6C5CE7)
    static let secondary = Color(hex: 0x00D2FF)
    static let success = Color(hex: 0x00E676)

    // MARK: - Status

    static let warning = Color(hex: 0xFF9100)
    static let danger = Color(hex: 0xFF5252)
    static let gold = Color(hex: 0xFFD700)
    static let emergency = danger

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x94A3B8)
    static let textMuted = Color(hex: 0x64748B)

    // MARK: - Border

    static let border = Color(hex: 0x1E293B)

    // MARK: - Legacy Aliases (backward-compatible)

    static let cardSurface = card
    static let tabBarBg = Color(hex: 0x0D1321)
    static let accentGreen = success
    static let teal = secondary
    static let unselectedTab = textMuted

    // MARK: - Gradients

    static let accentGradient = LinearGradient(
        colors: [accent, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [gold, Color(hex: 0xFFB300)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [success, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let meshBackground = MeshGradient(
        width: 3, height: 3,
        points: [
            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
        ],
        colors: [
            .black, Color(hex: 0x0A0F1E), .black,
            Color(hex: 0x6C5CE7).opacity(0.06), Color(hex: 0x0A0F1E), Color(hex: 0x00D2FF).opacity(0.04),
            .black, Color(hex: 0x6C5CE7).opacity(0.04), .black
        ]
    )

    // MARK: - Typography

    static func headingFont(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }

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
    static let colorTransition = Animation.easeOut(duration: 0.2)
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

// MARK: - Button Styles

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
