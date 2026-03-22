import SwiftUI
import SwiftData

nonisolated enum OnboardingScreen: Int, CaseIterable, Sendable {
    case welcome
    case choosePath
    case personalityQuiz
    case personalityReveal
    case currencySelection
    case firstWin
    case setupComplete
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    @State private var currentScreen: OnboardingScreen = .welcome
    @State private var savedAmount: Double = 0
    @State private var quizResult: QuizResult?
    @State private var selectedPath: UserPath?
    @State private var selectedCurrencyCode: String = "USD"
    @State private var selectedCurrencySymbol: String = "$"

    private var personality: MoneyPersonality {
        quizResult?.personality ?? .builder
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch currentScreen {
            case .welcome:
                SplurjWelcomeScreen {
                    advance(to: .choosePath)
                }

            case .choosePath:
                ChooseYourPathScreen(selectedPath: $selectedPath) {
                    advance(to: .personalityQuiz)
                }

            case .personalityQuiz:
                MoneyPersonalityQuizView(
                    onComplete: { result in
                        quizResult = result
                        modelContext.insert(result)
                        advance(to: .personalityReveal)
                    },
                    skipWelcome: true,
                    skipResult: true
                )

            case .personalityReveal:
                SplurjPersonalityRevealScreen(personality: personality) {
                    advance(to: .currencySelection)
                }

            case .currencySelection:
                CurrencySelectionScreen(
                    selectedCurrencyCode: $selectedCurrencyCode,
                    selectedCurrencySymbol: $selectedCurrencySymbol
                ) {
                    advance(to: .firstWin)
                }

            case .firstWin:
                FirstWinScreen(
                    personality: personality,
                    currencySymbol: selectedCurrencySymbol,
                    savedAmount: $savedAmount
                ) {
                    advance(to: .setupComplete)
                }

            case .setupComplete:
                SetupCompleteScreen(
                    personality: personality,
                    userPath: selectedPath ?? .generalSaver,
                    currencyCode: selectedCurrencyCode,
                    currencySymbol: selectedCurrencySymbol,
                    savedAmount: savedAmount,
                    modelContext: modelContext,
                    onComplete: onComplete
                )
            }
        }
    }

    private func advance(to screen: OnboardingScreen) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            currentScreen = screen
        }
    }
}
