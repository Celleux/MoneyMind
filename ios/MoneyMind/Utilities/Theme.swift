import SwiftUI

enum Theme {
    static let background = Color(red: 10/255, green: 10/255, blue: 15/255)
    static let cardSurface = Color(red: 26/255, green: 26/255, blue: 37/255)
    static let tabBarBg = Color(red: 18/255, green: 18/255, blue: 26/255)

    static let accentGreen = Color(red: 0, green: 230/255, blue: 118/255)
    static let teal = Color(red: 0, green: 191/255, blue: 165/255)
    static let gold = Color(red: 1, green: 215/255, blue: 64/255)
    static let emergency = Color(red: 1, green: 82/255, blue: 82/255)

    static let textPrimary = Color(red: 234/255, green: 234/255, blue: 234/255)
    static let textSecondary = Color(red: 158/255, green: 158/255, blue: 158/255)
    static let unselectedTab = Color(red: 97/255, green: 97/255, blue: 97/255)

    static let accentGradient = LinearGradient(
        colors: [accentGreen, teal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let goldGradient = LinearGradient(
        colors: [gold, Color(red: 1, green: 179/255, blue: 0)],
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
            .black, Color(red: 0.02, green: 0.04, blue: 0.08), .black,
            Color(red: 0, green: 0.12, blue: 0.08), Color(red: 0.02, green: 0.06, blue: 0.1), Color(red: 0, green: 0.06, blue: 0.1),
            .black, Color(red: 0, green: 0.08, blue: 0.06), .black
        ]
    )

    static func headingFont(_ style: Font.TextStyle, weight: Font.Weight = .bold) -> Font {
        .system(style, design: .rounded, weight: weight)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
