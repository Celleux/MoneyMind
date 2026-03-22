import SwiftUI
import SwiftData

nonisolated enum OnboardingScreen: Int, CaseIterable, Sendable {
    case welcome
    case personalityQuiz
    case personalityReveal
    case lossVisualization
    case firstWin
    case socialProof
    case intentionSetup
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    @State private var currentScreen: OnboardingScreen = .welcome
    @State private var savedAmount: Double = 0
    @State private var quizResult: QuizResult?
    @State private var showUrgeSurf = false

    private var personality: MoneyPersonality {
        quizResult?.personality ?? .builder
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch currentScreen {
            case .welcome:
                SplurjWelcomeScreen {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .personalityQuiz
                    }
                }

            case .personalityQuiz:
                MoneyPersonalityQuizView(
                    onComplete: { result in
                        quizResult = result
                        modelContext.insert(result)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .personalityReveal
                        }
                    },
                    skipWelcome: true,
                    skipResult: true
                )

            case .personalityReveal:
                SplurjPersonalityRevealScreen(personality: personality) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .lossVisualization
                    }
                }

            case .lossVisualization:
                LossVisualizationScreen {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .firstWin
                    }
                }

            case .firstWin:
                FirstWinScreen(savedAmount: $savedAmount) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .socialProof
                    }
                }

            case .socialProof:
                SocialProofScreen {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .intentionSetup
                    }
                }

            case .intentionSetup:
                IntentionScreen(modelContext: modelContext, onComplete: onComplete)
            }
        }
        .sheet(isPresented: $showUrgeSurf) {
            UrgeSurfSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
