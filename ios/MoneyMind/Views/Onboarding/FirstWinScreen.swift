import SwiftUI

struct FirstWinScreen: View {
    let personality: MoneyPersonality
    var currencySymbol: String = "$"
    @Binding var savedAmount: Double
    let onNext: () -> Void

    @State private var amountText: String = ""
    @State private var showCelebration = false
    @State private var coinOffset: CGFloat = 0
    @State private var coinOpacity: Double = 1
    @State private var coinScale: Double = 1
    @State private var counterValue: Double = 0
    @State private var confettiTrigger: Int = 0
    @State private var appeared = false
    @FocusState private var amountFocused: Bool

    private var enteredAmount: Double {
        Double(amountText) ?? 0
    }

    private var personalityPrompt: String {
        switch personality {
        case .hustler: "That impulse Amazon order? The 2 AM Uber Eats?"
        case .generous: "That gift you almost bought? The extra round of drinks?"
        case .saver: "Even you have weak moments. That streaming subscription upgrade?"
        case .minimalist: "That 'just one more thing' you almost added to cart?"
        case .builder: "That crypto dip you almost FOMO'd into?"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if showCelebration {
                celebrationView
            } else {
                inputView
            }

            Spacer()

            if !showCelebration {
                Button {
                    guard enteredAmount > 0 else { return }
                    savedAmount = enteredAmount
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showCelebration = true
                    }
                    playCoinAnimation()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.subheadline)
                        Text("I Saved This!")
                    }
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        enteredAmount > 0
                            ? AnyShapeStyle(Theme.goldGradient)
                            : AnyShapeStyle(Color.gray.opacity(0.3)),
                        in: .rect(cornerRadius: 12)
                    )
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(enteredAmount <= 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .sensoryFeedback(.impact(weight: .heavy), trigger: showCelebration)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                appeared = true
            }
            amountFocused = true
        }
    }

    private var inputView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("Log Your First Save")
                    .font(Theme.headingFont(.title))
                    .foregroundStyle(Theme.gold)

                Text("Think of something you resisted\nbuying recently. How much was it?")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                Text(personalityPrompt)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(personality.color.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            VStack(spacing: 8) {
                Text("How much was it?")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(currencySymbol)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    TextField("0", text: $amountText)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .keyboardType(.decimalPad)
                        .focused($amountFocused)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                }
            }
            .padding(32)
            .glassCard(cornerRadius: 20)
        }
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var celebrationView: some View {
        VStack(spacing: 32) {
            ZStack {
                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.accentGradient)

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.gold)
                    .scaleEffect(coinScale)
                    .opacity(coinOpacity)
                    .offset(y: coinOffset)
            }

            confettiOverlay

            VStack(spacing: 12) {
                Text("\(currencySymbol)\(counterValue, specifier: "%.0f") saved!")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText(value: counterValue))

                Text("You just made your first smart decision.\nThat feeling? Remember it.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                onNext()
            } label: {
                Text("Keep Going")
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var confettiOverlay: some View {
        HStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill([Theme.gold, Theme.accentGreen, Theme.teal, Theme.gold, Theme.accentGreen][i])
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat.random(in: -40...40),
                        y: CGFloat(confettiTrigger) > 0 ? CGFloat.random(in: -60 ... -20) : 0
                    )
                    .opacity(confettiTrigger > 0 ? 0 : 1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5).delay(Double(i) * 0.05),
                        value: confettiTrigger
                    )
            }
        }
    }

    private func playCoinAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            coinOffset = -80
            coinScale = 0.3
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.4)) {
            coinOpacity = 0
        }
        confettiTrigger += 1

        withAnimation(.spring(response: 0.8).delay(0.3)) {
            counterValue = enteredAmount
        }
    }
}
