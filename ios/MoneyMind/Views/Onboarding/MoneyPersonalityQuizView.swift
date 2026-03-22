import SwiftUI

struct MoneyPersonalityQuizView: View {
    let onComplete: (QuizResult) -> Void
    var skipWelcome: Bool = false
    var skipResult: Bool = false

    @State private var phase: QuizPhase = .welcome
    @State private var currentQuestion: Int = 0
    @State private var answers: [String] = []
    @State private var selectedAnswer: String?
    @State private var computedPersonality: MoneyPersonality?
    @State private var showCard = false
    @State private var revealPulse = false
    @State private var revealDone = false

    private let questions: [(question: String, options: [(emoji: String, text: String)])] = [
        (
            "When you get unexpected money, you...",
            [("🏦", "Save it all"), ("🎉", "Spend on something fun"), ("📈", "Invest it"), ("🎁", "Share it with others")]
        ),
        (
            "Your ideal Saturday involves...",
            [("📊", "Budget planning"), ("🛍️", "Shopping therapy"), ("💻", "Working on a side hustle"), ("🌳", "Free activities with friends")]
        ),
        (
            "Money makes you feel...",
            [("🛡️", "Secure"), ("🕊️", "Free"), ("⚡", "Powerful"), ("😰", "Anxious")]
        ),
        (
            "Your friends say you're the one who...",
            [("💰", "Always saves"), ("🍽️", "Treats everyone"), ("✈️", "Invests in experiences"), ("🔍", "Finds the best deals")]
        ),
        (
            "Your financial superpower is...",
            [("⏳", "Patience"), ("💝", "Generosity"), ("🎲", "Risk-taking"), ("🎯", "Discipline")]
        )
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch phase {
            case .welcome:
                welcomeScreen
                    .transition(.opacity)
                    .onAppear {
                        if skipWelcome {
                            phase = .quiz
                        }
                    }
            case .quiz:
                quizScreen
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .revealing:
                revealScreen
                    .transition(.opacity)
            case .result:
                resultScreen
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Welcome

    private var welcomeScreen: some View {
        QuizWelcomeScreen {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                phase = .quiz
            }
        }
    }

    // MARK: - Quiz

    private var quizScreen: some View {
        let q = questions[currentQuestion]

        return VStack(spacing: 0) {
            quizProgressBar
                .padding(.top, 16)
                .padding(.horizontal, 24)

            Spacer().frame(height: 40)

            Text("Q\(currentQuestion + 1) of 5")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .textCase(.uppercase)
                .tracking(2)

            Spacer().frame(height: 16)

            Text(q.question)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .id("question_\(currentQuestion)")
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            Spacer().frame(height: 32)

            VStack(spacing: 12) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { index, option in
                    let isSelected = selectedAnswer == option.text

                    Button {
                        guard selectedAnswer == nil else { return }
                        selectedAnswer = option.text
                    } label: {
                        HStack(spacing: 14) {
                            Text(option.emoji)
                                .font(.title2)

                            Text(option.text)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.white)

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Theme.accent)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .glassCard(cornerRadius: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    isSelected ? Theme.accent : Color.clear,
                                    lineWidth: isSelected ? 1.5 : 0
                                )
                        )
                        .scaleEffect(isSelected ? 1.02 : 1.0)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.impact(weight: .light), trigger: isSelected)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                    .opacity(selectedAnswer != nil && !isSelected ? 0.5 : 1.0)
                    .animation(.easeOut(duration: 0.2), value: selectedAnswer)
                }
            }
            .padding(.horizontal, 24)
            .id("options_\(currentQuestion)")
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            Spacer()
        }
        .onChange(of: selectedAnswer) { _, newValue in
            guard let answer = newValue else { return }
            Task {
                try? await Task.sleep(for: .milliseconds(500))
                answers.append(answer)
                selectedAnswer = nil

                if currentQuestion < 4 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        currentQuestion += 1
                    }
                } else {
                    let personality = QuizResult.computePersonality(answers: answers)
                    computedPersonality = personality
                    if skipResult {
                        let result = QuizResult(answers: answers)
                        onComplete(result)
                    } else {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            phase = .revealing
                        }
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            phase = .result
                        }
                    }
                }
            }
        }
    }

    private var quizProgressBar: some View {
        GeometryReader { geo in
            let progress = CGFloat(currentQuestion + (selectedAnswer != nil ? 1 : 0)) / 5.0

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.elevated)
                    .frame(height: 4)

                Capsule()
                    .fill(Theme.accent)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Reveal

    private var revealScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .strokeBorder(
                            (computedPersonality?.color ?? Theme.accent).opacity(0.15 - Double(ring) * 0.04),
                            lineWidth: 2
                        )
                        .frame(width: CGFloat(100 + ring * 40), height: CGFloat(100 + ring * 40))
                        .scaleEffect(revealPulse ? 1.15 : 0.9)
                        .opacity(revealPulse ? 0.3 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(ring) * 0.2),
                            value: revealPulse
                        )
                }

                Image(systemName: computedPersonality?.icon ?? "sparkles")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(computedPersonality?.color ?? Theme.accent)
                    .symbolEffect(.pulse, options: .repeating)
            }

            Text("Analyzing your\nmoney personality...")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .onAppear {
            revealPulse = true
        }
    }

    // MARK: - Result

    private var resultScreen: some View {
        let personality = computedPersonality ?? .builder

        return ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("YOUR MONEY PERSONALITY")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                    .tracking(3)
                    .opacity(showCard ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: showCard)

                Spacer().frame(height: 24)

                personalityCard(personality)
                    .padding(.horizontal, 32)
                    .opacity(showCard ? 1 : 0)
                    .offset(y: showCard ? 0 : 40)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: showCard)

                Spacer().frame(height: 32)

                Text("This is a self-reflection tool, not a clinical assessment.")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(Theme.textMuted.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showCard ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.6), value: showCard)

                Spacer().frame(height: 24)

                VStack(spacing: 12) {
                    ShareLink(
                        item: personalityShareText(personality),
                        preview: SharePreview(
                            "My Money Personality",
                            image: Image(systemName: personality.icon)
                        )
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Share My Personality")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(personality.color, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        let result = QuizResult(answers: answers)
                        onComplete(result)
                    } label: {
                        Text("Start Managing Money")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.elevated, in: .rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.border, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 32)
                .opacity(showCard ? 1 : 0)
                .animation(.easeOut(duration: 0.3).delay(0.8), value: showCard)

                Spacer().frame(height: 40)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            showCard = true
        }
    }

    private func personalityCard(_ personality: MoneyPersonality) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(personality.color.opacity(0.12))
                    .frame(width: 88, height: 88)

                Image(systemName: personality.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(personality.color)
            }

            VStack(spacing: 8) {
                Text(personality.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(personality.color)

                HStack(spacing: 8) {
                    ForEach(personality.traits, id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(personality.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(personality.color.opacity(0.12), in: .capsule)
                    }
                }
            }

            Text(personality.description)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func personalityShareText(_ personality: MoneyPersonality) -> String {
        "I'm \(personality.rawValue) 🧠\n\n\(personality.traits.joined(separator: " · "))\n\n\(personality.description)\n\nDiscover yours on Splurj!"
    }
}

nonisolated enum QuizPhase: Sendable {
    case welcome, quiz, revealing, result
}
