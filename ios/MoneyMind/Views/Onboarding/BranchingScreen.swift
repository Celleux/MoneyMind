import SwiftUI

struct BranchingScreen: View {
    let onCrisis: () -> Void
    let onUnderstand: () -> Void
    let onCommunity: () -> Void

    @State private var appeared = false
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("What feels right\nfor you right now?")
                    .font(Theme.headingFont(.title))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                Text("No wrong answers. You can explore everything later.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .padding(.bottom, 32)

            VStack(spacing: 16) {
                BranchCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "I need help RIGHT NOW",
                    subtitle: "Quick tools to ride out an urge",
                    color: Theme.emergency,
                    hasPulse: true,
                    pulseScale: pulseScale,
                    action: onCrisis
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5).delay(0.1), value: appeared)

                BranchCard(
                    icon: "brain.fill",
                    title: "Help me understand myself",
                    subtitle: "3 quick questions about your patterns",
                    color: Theme.teal,
                    hasPulse: false,
                    pulseScale: 1,
                    action: onUnderstand
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5).delay(0.2), value: appeared)

                BranchCard(
                    icon: "person.3.fill",
                    title: "Show me what others are doing",
                    subtitle: "See how the community is winning",
                    color: Theme.accentGreen,
                    hasPulse: false,
                    pulseScale: 1,
                    action: onCommunity
                )
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.spring(response: 0.5).delay(0.3), value: appeared)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.03
            }
        }
    }
}

private struct BranchCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let hasPulse: Bool
    let pulseScale: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.15), in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color.opacity(0.6))
            }
            .padding(20)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: title)
    }
}
