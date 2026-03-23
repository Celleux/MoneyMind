import SwiftUI

struct SpendingPatternCardsView: View {
    @Binding var dna: FinancialDNA
    @Binding var cardAnswers: [String]
    let onComplete: () -> Void

    @State private var currentCard: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var hapticTrigger: Int = 0
    @State private var showSwipeHint: Bool = true
    @State private var swipeHintPhase: Bool = false

    private let scenarios = SpendingScenario.all

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                ForEach(0..<scenarios.count, id: \.self) { i in
                    Circle()
                        .fill(dotColor(for: i))
                        .frame(width: 8, height: 8)
                        .scaleEffect(i == currentCard ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3), value: currentCard)
                }
            }
            .padding(.top, 20)

            Text("\(currentCard + 1) of \(scenarios.count)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .tracking(1)
                .padding(.top, 10)

            Spacer()

            ZStack {
                if currentCard + 1 < scenarios.count {
                    ScenarioCardView(scenario: scenarios[currentCard + 1], response: nil)
                        .scaleEffect(0.92)
                        .opacity(0.3)
                }

                if currentCard < scenarios.count {
                    ScenarioCardView(
                        scenario: scenarios[currentCard],
                        response: dragDirection
                    )
                    .offset(dragOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .gesture(cardDragGesture)
                    .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            if showSwipeHint {
                swipeHandHint
                    .transition(.opacity)
                    .padding(.bottom, 8)
            }

            swipeHints
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
    }

    private var dragDirection: SwipeDirection? {
        if dragOffset.width > 50 { return .right }
        if dragOffset.width < -50 { return .left }
        return nil
    }

    private func dotColor(for index: Int) -> Color {
        if index < currentCard { return Theme.accent }
        if index == currentCard { return .white }
        return Theme.elevated
    }

    private var swipeHandHint: some View {
        HStack(spacing: 24) {
            Image(systemName: "arrow.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: 0x60A5FA).opacity(0.6))
                .offset(x: swipeHintPhase ? -4 : 0)

            Image(systemName: "hand.point.up.fill")
                .font(.system(size: 28))
                .foregroundStyle(.white.opacity(0.7))
                .offset(x: swipeHintPhase ? 30 : -30)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: swipeHintPhase
                )

            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(hex: 0xFB923C).opacity(0.6))
                .offset(x: swipeHintPhase ? 4 : 0)
        }
        .animation(
            .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
            value: swipeHintPhase
        )
        .onAppear {
            swipeHintPhase = true
        }
    }

    private var swipeHints: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left")
                Text(currentCard < scenarios.count ? scenarios[currentCard].leftLabel : "")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(
                Color(hex: 0x60A5FA).opacity(
                    abs(dragOffset.width) > 50 && dragOffset.width < 0 ? 1.0 : 0.4
                )
            )

            Spacer()

            HStack(spacing: 6) {
                Text(currentCard < scenarios.count ? scenarios[currentCard].rightLabel : "")
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Image(systemName: "arrow.right")
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(
                Color(hex: 0xFB923C).opacity(
                    abs(dragOffset.width) > 50 && dragOffset.width > 0 ? 1.0 : 0.4
                )
            )
        }
    }

    private var cardDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                cardRotation = Double(value.translation.width / 20)
            }
            .onEnded { value in
                if abs(value.translation.width) > 100 {
                    let swipedRight = value.translation.width > 0
                    recordAnswer(scenario: scenarios[currentCard], swipedRight: swipedRight)
                    hapticTrigger += 1

                    if showSwipeHint {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSwipeHint = false
                        }
                    }

                    withAnimation(.spring(response: 0.3)) {
                        dragOffset = CGSize(
                            width: swipedRight ? 500 : -500,
                            height: value.translation.height
                        )
                    }

                    Task {
                        try? await Task.sleep(for: .milliseconds(300))
                        dragOffset = .zero
                        cardRotation = 0
                        currentCard += 1
                        if currentCard >= scenarios.count {
                            onComplete()
                        }
                    }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        dragOffset = .zero
                        cardRotation = 0
                    }
                }
            }
    }

    private func recordAnswer(scenario: SpendingScenario, swipedRight: Bool) {
        let adjustment = swipedRight ? 0.15 : -0.15

        switch scenario.axis {
        case .spending:
            dna.spendingAxis = max(0, min(1, dna.spendingAxis + adjustment))
        case .emotional:
            dna.emotionalAxis = max(0, min(1, dna.emotionalAxis + adjustment))
        case .risk:
            dna.riskAxis = max(0, min(1, dna.riskAxis + adjustment))
        case .social:
            dna.socialAxis = max(0, min(1, dna.socialAxis + adjustment))
        }

        cardAnswers.append(swipedRight ? "right" : "left")
    }
}
