import SwiftUI
import RiveRuntime

struct SplurjRiveView: View {
    let fileName: String
    var stateMachineName: String = "MainState"
    @State private var riveVM: RiveViewModel?
    @State private var loadFailed: Bool = false

    var body: some View {
        Group {
            if let vm = riveVM {
                vm.view()
            } else if loadFailed {
                placeholderView
            } else {
                Color.clear
                    .onAppear { loadRive() }
            }
        }
    }

    private func loadRive() {
        if Bundle.main.url(forResource: fileName, withExtension: "riv") != nil {
            riveVM = RiveViewModel(fileName: fileName, stateMachineName: stateMachineName)
        } else {
            loadFailed = true
        }
    }

    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Theme.accent)
            Text("Animation coming soon")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Theme.textMuted)
        }
    }

    func setInput(_ name: String, boolValue: Bool) {
        riveVM?.setInput(name, value: boolValue)
    }

    func setInput(_ name: String, doubleValue: Double) {
        riveVM?.setInput(name, value: doubleValue)
    }

    func triggerInput(_ name: String) {
        riveVM?.triggerInput(name)
    }
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

    @State private var hasRiveFile: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if hasRiveFile {
                SplurjRiveView(fileName: "splurji", stateMachineName: "MainState")
            } else {
                fallbackMascot
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .onAppear {
            hasRiveFile = Bundle.main.url(forResource: "splurji", withExtension: "riv") != nil
        }
        .accessibilityLabel("Splurji mascot, current mood: \(mood.rawValue)")
    }

    private var fallbackMascot: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.neonEmerald.opacity(0.3), Theme.accent.opacity(0.1)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.dimension / 2
                    )
                )

            Image(systemName: moodIcon)
                .font(.system(size: size.dimension * 0.4, weight: .bold))
                .foregroundStyle(Theme.accent)
                .symbolEffect(
                    .pulse,
                    options: reduceMotion ? .nonRepeating : .repeating,
                    isActive: mood == .celebrating || mood == .happy
                )
        }
    }

    private var moodIcon: String {
        switch mood {
        case .idle: return "face.smiling"
        case .happy: return "face.smiling.fill"
        case .celebrating: return "party.popper"
        case .sad: return "face.dashed"
        case .thinking: return "brain.head.profile"
        case .sleeping: return "zzz"
        case .encouraging: return "hand.thumbsup.fill"
        case .proud: return "star.fill"
        }
    }
}
