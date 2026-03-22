import SwiftUI

struct WeekSavingsView: View {
    @Bindable var challenge: SavingsChallenge
    @Bindable var vm: ChallengesViewModel
    let personalityColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var shareTrigger = false

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsHeader
                    progressBar
                    weekGrid
                    shareSection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("52-Week Savings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
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
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                        Text("of 52")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Saved")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text("$\(Int(challenge.totalSaved))")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(personalityColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Goal")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                    Text("$1,378")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
            }

            Spacer()
        }
        .padding(20)
        .glassCard()
        .padding(.top, 8)
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(Int(challenge.progress * 100))%")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(personalityColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.elevated)
                        .frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [personalityColor, Theme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * challenge.progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .glassCard(cornerRadius: 12)
    }

    private var weekGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(1...52, id: \.self) { week in
                WeekCell(
                    week: week,
                    amount: week,
                    isCompleted: challenge.completedItems.contains(week),
                    personalityColor: personalityColor
                ) {
                    guard !challenge.completedItems.contains(week) else { return }
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        vm.markWeek(week, challenge: challenge)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .animation(
                    .easeOut(duration: 0.3).delay(Double(week) * 0.008),
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
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.accent.opacity(0.1), in: .rect(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
        .sheet(isPresented: $shareTrigger) {
            let text = vm.shareChallenge(challenge)
            ShareSheetView(items: [text])
                .presentationDetents([.medium])
        }
    }
}

private struct WeekCell: View {
    let week: Int
    let amount: Int
    let isCompleted: Bool
    let personalityColor: Color
    let action: () -> Void

    @State private var checkScale: CGFloat = 0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack {
                    Text("W\(week)")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(isCompleted ? personalityColor : Theme.textMuted)
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.success)
                            .scaleEffect(checkScale)
                            .onAppear {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                    checkScale = 1
                                }
                            }
                    }
                }

                Text("$\(amount)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(isCompleted ? personalityColor : Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .background(
                isCompleted ? personalityColor.opacity(0.1) : Theme.elevated,
                in: .rect(cornerRadius: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isCompleted ? personalityColor.opacity(0.3) : Theme.border,
                        lineWidth: isCompleted ? 1 : 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isCompleted)
        .accessibilityLabel("Week \(week), $\(amount), \(isCompleted ? "completed" : "available")")
    }
}
