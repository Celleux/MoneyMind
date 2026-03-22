import SwiftUI

struct CommunityGuidelinesOverlay: View {
    let onAgree: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        VStack(spacing: 16) {
                            ForEach(Array(CommunityContent.guidelines.enumerated()), id: \.offset) { index, guideline in
                                guidelineRow(guideline, delay: Double(index) * 0.06)
                            }
                        }

                        disclaimerSection
                    }
                    .padding(24)
                }

                agreeButton
            }
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 24))
            .padding(.horizontal, 20)
            .padding(.vertical, 60)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.92)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.accentGreen.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: "shield.checkered")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.accentGreen)
            }

            Text("Community Guidelines")
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)

            Text("A safe space for everyone on their financial wellness journey")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func guidelineRow(_ guideline: (icon: String, title: String, description: String), delay: Double) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.accentGreen.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: guideline.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accentGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(guideline.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                Text(guideline.description)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineSpacing(2)
            }

            Spacer(minLength: 0)
        }
    }

    private var disclaimerSection: some View {
        Text("MoneyMind is a peer support community, not a substitute for professional help. If you're in crisis, tap the SOS button anytime.")
            .font(.caption)
            .foregroundStyle(Theme.textSecondary.opacity(0.7))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
    }

    private var agreeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onAgree()
            }
        } label: {
            Text("I Agree — Let's Go")
                .font(.headline)
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: appeared)
        .accessibilityLabel("Agree to community guidelines")
        .padding(20)
    }
}
