import SwiftUI

struct SplurjRiveView: View {
    let fileName: String
    var stateMachineName: String = "MainState"

    var body: some View {
        placeholderView
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(Typography.displaySmall)
                .foregroundStyle(Theme.accent)
            Text("Animation coming soon")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textMuted)
        }
    }

    func setInput(_ name: String, boolValue: Bool) {}
    func setInput(_ name: String, doubleValue: Double) {}
    func triggerInput(_ name: String) {}
}

enum SplurjiMood: String, CaseIterable {
    case idle, happy, celebrating, sad, thinking, sleeping, encouraging, proud
}

struct RiveMascotView: View {
    let mood: SplurjiMood
    let size: MascotSize

    enum MascotSize {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 120
            case .large: return 200
            }
        }
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        SplurjiCharacter(mood: mood, size: size.dimension)
            .frame(width: size.dimension, height: size.dimension)
            .accessibilityLabel("Splurji mascot, current mood: \(mood.rawValue)")
    }
}
