import SwiftUI
import SwiftData

nonisolated enum OnboardingScreen: Int, CaseIterable, Sendable {
    case splash, lossVisualization, firstWin, branching, miniQuiz, socialProof, accountCreation, intention
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    let onComplete: () -> Void

    @State private var currentScreen: OnboardingScreen = .splash
    @State private var savedAmount: Double = 0
    @State private var quizResult: QuizResult?
    @State private var showUrgeSurf = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch currentScreen {
            case .splash:
                SplashOnboardingScreen {
                    withAnimation(.easeInOut(duration: 0.5)) {
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
                        currentScreen = .branching
                    }
                }
            case .branching:
                BranchingScreen(
                    onCrisis: {
                        showUrgeSurf = true
                    },
                    onUnderstand: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .miniQuiz
                        }
                    },
                    onCommunity: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .socialProof
                        }
                    }
                )
            case .miniQuiz:
                MiniQuizScreen { result in
                    quizResult = result
                    modelContext.insert(result)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .accountCreation
                    }
                }
            case .socialProof:
                SocialProofScreen {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .accountCreation
                    }
                }
            case .accountCreation:
                AccountCreationScreen(savedAmount: savedAmount) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        currentScreen = .intention
                    }
                }
            case .intention:
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
