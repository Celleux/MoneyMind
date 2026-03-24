import SwiftUI

struct EnvelopeChallengeView: View {
    @Bindable var challenge: SavingsChallenge
    @Bindable var vm: ChallengesViewModel
    let personalityColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var flippedEnvelope: Int?
    @State private var shareTrigger = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 10)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsHeader
                    dailySuggestion
                    envelopeGrid
                    shareSection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("100 Envelopes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(Typography.headingLarge)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .overlay {
                if vm.showCelebration {
                    ChallengesCelebrationOverlay(
                        message: vm.celebrationMessage,
                        particles: vm.confettiParticles
                    ) {
                        vm.showCelebration = false
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: vm.hapticTrigger)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 20) {
            MMProgressRing(progress: challenge.progress, lineWidth: 8, size: 90)
                .overlay {
                    VStack(spacing: 2) {
                        Text("\(challenge.completedItems.count)")
                            .font(Typography.displaySmall)
                            .foregroundStyle(Theme.textPrimary)
                        Text("of 100")
                            .font(Typography.labelSmall)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Saved")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text("$\(Int(challenge.totalSaved))")
                        .font(Typography.displayMedium)
                        .foregroundStyle(personalityColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remaining")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text("$\(Int(5050 - challenge.totalSaved))")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            Spacer()
        }
        .padding(20)
        .splurjCard(.hero)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var dailySuggestion: some View {
        if let suggested = challenge.dailySuggestedEnvelope {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(Typography.headingLarge)
                    .foregroundStyle(Theme.gold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's Suggestion")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text("Save $\(suggested) — tap envelope #\(suggested)")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Theme.gold.opacity(0.08), Theme.card],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.gold.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private var envelopeGrid: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(1...100, id: \.self) { number in
                EnvelopeCell(
                    number: number,
                    isCompleted: challenge.completedItems.contains(number),
                    isSuggested: challenge.dailySuggestedEnvelope == number,
                    isFlipping: flippedEnvelope == number,
                    personalityColor: personalityColor
                ) {
                    guard !challenge.completedItems.contains(number) else { return }
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        flippedEnvelope = number
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            vm.markEnvelope(number, challenge: challenge)
                            flippedEnvelope = nil
                        }
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(
                    .easeOut(duration: 0.3).delay(Double(number) * 0.003),
                    value: appeared
                )
            }
        }
    }

    private var shareSection: some View {
        Button {
            shareTrigger = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Progress")
            }
            .font(Typography.headingSmall)
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.accent.opacity(0.1), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(SplurjButtonStyle(variant: .secondary, size: .medium))
        .sheet(isPresented: $shareTrigger) {
            let text = vm.shareChallenge(challenge)
            ShareSheetView(items: [text])
                .presentationDetents([.medium])
        }
    }
}

private struct EnvelopeCell: View {
    let number: Int
    let isCompleted: Bool
    let isSuggested: Bool
    let isFlipping: Bool
    let personalityColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isCompleted {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(personalityColor.opacity(0.25))
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(personalityColor.opacity(0.5), lineWidth: 1)
                    Text("\(number)")
                        .font(Typography.labelSmall)
                        .foregroundStyle(personalityColor)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSuggested ? Theme.gold.opacity(0.12) : Theme.elevated)
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isSuggested ? Theme.gold.opacity(0.4) : Theme.border,
                            lineWidth: isSuggested ? 1.5 : 0.5
                        )
                    Text("\(number)")
                        .font(Typography.labelSmall)
                        .foregroundStyle(isSuggested ? Theme.gold : Theme.textMuted)
                }
            }
            .frame(height: 32)
            .rotation3DEffect(
                .degrees(isFlipping ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
        .accessibilityLabel("Envelope \(number), \(isCompleted ? "saved" : "available")")
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
