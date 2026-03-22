import SwiftUI

struct ChooseYourPathScreen: View {
    @Binding var selectedPath: UserPath?
    let onNext: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            VStack(spacing: 8) {
                Text("What brings you to Splurj?")
                    .font(Theme.headingFont(.title))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Pick the one that resonates most.\nYou'll get access to everything.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            Spacer().frame(height: 28)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(UserPath.allCases.enumerated()), id: \.element) { index, path in
                        let isSelected = selectedPath == path

                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedPath = path
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(path.emoji)
                                    .font(.system(size: 28))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        isSelected ? Theme.accent.opacity(0.12) : Theme.accent.opacity(0.06),
                                        in: .rect(cornerRadius: 12)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(path.title)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.textPrimary)

                                    Text(path.subtitle)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(Theme.textSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(Theme.accent)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(16)
                            .glassCard(cornerRadius: 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        isSelected ? Theme.accent.opacity(0.5) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: isSelected ? Theme.accent.opacity(0.15) : .clear,
                                radius: 8, y: 2
                            )
                        }
                        .buttonStyle(PressableButtonStyle())
                        .sensoryFeedback(.selection, trigger: isSelected)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                        .animation(.spring(response: 0.5).delay(0.1 + Double(index) * 0.08), value: appeared)
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollBounceBehavior(.basedOnSize)

            VStack(spacing: 12) {
                if selectedPath != nil {
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.impact(weight: .medium), trigger: selectedPath != nil)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Text("You can change this anytime in Settings")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 36)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedPath)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }
}
