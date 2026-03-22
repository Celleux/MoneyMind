import SwiftUI

struct MiniQuizScreen: View {
    let onComplete: (QuizResult) -> Void

    @State private var currentQuestion = 0
    @State private var stressResponse: String = ""
    @State private var biggestTrigger: String = ""
    @State private var desiredFeeling: String = ""
    @State private var showResult = false
    @State private var appeared = false

    private let questions: [(String, [String])] = [
        ("When I feel stressed about money, I tend to...", ["Spend", "Gamble", "Avoid"]),
        ("My biggest financial trigger is...", ["Boredom", "Stress", "Social pressure", "FOMO"]),
        ("I want to feel...", ["In control", "Less anxious", "Free", "Proud"])
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i <= currentQuestion ? Theme.teal : Theme.cardSurface)
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            if showResult {
                resultView
            } else {
                questionView
            }

            Spacer()
        }
    }

    private var questionView: some View {
        let q = questions[currentQuestion]

        return VStack(spacing: 36) {
            VStack(spacing: 8) {
                Text("Question \(currentQuestion + 1) of 3")
                    .font(.caption)
                    .foregroundStyle(Theme.teal)

                Text(q.0)
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.3), value: currentQuestion)

            VStack(spacing: 12) {
                ForEach(q.1, id: \.self) { option in
                    let isSelected = selectedValue(for: currentQuestion) == option
                    Button {
                        selectOption(option)
                    } label: {
                        Text(option)
                            .font(.headline)
                            .foregroundStyle(isSelected ? Theme.background : Theme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isSelected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.cardSurface),
                                in: .rect(cornerRadius: 12)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isSelected ? Color.clear : Theme.teal.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
            .padding(.horizontal, 24)
        }
        .onAppear { appeared = true }
    }

    private var resultView: some View {
        let result = QuizResult(
            stressResponse: stressResponse,
            biggestTrigger: biggestTrigger,
            desiredFeeling: desiredFeeling
        )

        return VStack(spacing: 28) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Theme.gold)

            VStack(spacing: 8) {
                Text("Your Money Personality")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .textCase(.uppercase)
                    .tracking(2)

                Text(result.personalityType)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accentGradient)
            }

            VStack(spacing: 4) {
                Text("Trigger: \(biggestTrigger)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Text("Goal: \(desiredFeeling)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
            .background(Theme.cardSurface, in: .rect(cornerRadius: 12))

            Text("This is a self-reflection tool, not a clinical assessment.")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                onComplete(result)
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, 24)
        .transition(.scale.combined(with: .opacity))
    }

    private func selectedValue(for question: Int) -> String {
        switch question {
        case 0: return stressResponse
        case 1: return biggestTrigger
        case 2: return desiredFeeling
        default: return ""
        }
    }

    private func selectOption(_ option: String) {
        switch currentQuestion {
        case 0: stressResponse = option
        case 1: biggestTrigger = option
        case 2: desiredFeeling = option
        default: break
        }

        Task {
            try? await Task.sleep(for: .milliseconds(400))
            if currentQuestion < 2 {
                withAnimation(.spring(response: 0.4)) {
                    currentQuestion += 1
                }
            } else {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showResult = true
                }
            }
        }
    }
}
