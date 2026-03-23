import SwiftUI
import RiveRuntime

protocol SplurjCharacterProtocol {
    var currentMood: SplurjiMood { get }
    func setMood(_ mood: SplurjiMood)
    func triggerAnimation(_ name: String)
}

struct SplurjiWithBubble: View {
    let mood: SplurjiMood
    let size: CGFloat
    let message: String
    let showBubble: Bool
    var onBubbleDismiss: () -> Void = {}
    var onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 4) {
            if showBubble && !message.isEmpty {
                SpeechBubble(message: message, onDismiss: onBubbleDismiss)
                    .transition(.scale.combined(with: .opacity))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: size * 2.5)
            }

            SplurjiCharacterView(mood: mood, size: size)
        }
        .onTapGesture {
            onTap?()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showBubble)
    }
}

struct SplurjiCharacterView: View {
    let mood: SplurjiMood
    let size: CGFloat
    @State private var hasRiveFile: Bool = false

    var body: some View {
        Group {
            if hasRiveFile {
                SplurjRiveView(fileName: "splurji", stateMachineName: "MainState")
            } else {
                SplurjiCharacter(mood: mood, size: size)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            hasRiveFile = Bundle.main.url(forResource: "splurji", withExtension: "riv") != nil
        }
        .accessibilityLabel("Splurji mascot, current mood: \(mood.rawValue)")
    }
}
