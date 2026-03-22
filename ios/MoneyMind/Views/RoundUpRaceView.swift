import SwiftUI
import SwiftData

struct RoundUpRaceView: View {
    @Bindable var challenge: SavingsChallenge
    @Bindable var vm: ChallengesViewModel
    let personalityColor: Color
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false
    @State private var piggyScale: CGFloat = 1.0
    @State private var coinDrop = false
    @State private var shareTrigger = false
    @State private var processedTransactionCount = 0

    private var roundUpTransactions: [(String, Double, Date)] {
        transactions
            .filter { $0.transactionType == .expense }
            .compactMap { tx in
                let rounded = ceil(tx.amount)
                let diff = rounded - tx.amount
                guard diff > 0.001 else { return nil }
                return (tx.note.isEmpty ? tx.category : tx.note, diff, tx.date)
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    piggyBankSection
                    statsRow
                    roundUpHistory
                    shareSection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Round-Up Race")
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        syncRoundUps()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.accent)
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
                withAnimation(.easeOut(duration: 0.6)) { appeared = true }
                syncRoundUps()
            }
        }
    }

    private var piggyBankSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(personalityColor.opacity(0.06))
                    .frame(width: 160, height: 160)

                Circle()
                    .fill(personalityColor.opacity(0.1))
                    .frame(width: 120, height: 120)

                ZStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(personalityColor)
                        .scaleEffect(piggyScale)

                    if coinDrop {
                        Image(systemName: "centsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Theme.gold)
                            .offset(y: -50)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    piggyScale = 1.06
                }
            }

            VStack(spacing: 6) {
                Text("$\(String(format: "%.2f", challenge.roundUpTotal))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(personalityColor)

                Text("saved from round-ups")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.elevated)
                        .frame(height: 10)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [personalityColor, Theme.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(1.0, challenge.roundUpTotal / 100.0), height: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("$0")
                    .font(.caption2)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Text("Next milestone: $\(nextMilestone)")
                    .font(.caption2)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(24)
        .glassCard(cornerRadius: 20)
        .padding(.top, 8)
    }

    private var nextMilestone: Int {
        let milestones = [10, 25, 50, 100, 250, 500, 1000]
        return milestones.first(where: { Double($0) > challenge.roundUpTotal }) ?? 1000
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(challenge.daysActive)", label: "Days Active", icon: "clock.fill")
            Divider().frame(height: 32).background(Theme.textSecondary.opacity(0.2))
            statItem(value: "\(roundUpTransactions.count)", label: "Round-Ups", icon: "arrow.up.circle.fill")
            Divider().frame(height: 32).background(Theme.textSecondary.opacity(0.2))
            let avg = roundUpTransactions.isEmpty ? 0 : challenge.roundUpTotal / Double(roundUpTransactions.count)
            statItem(value: String(format: "$%.2f", avg), label: "Avg Round-Up", icon: "chart.bar.fill")
        }
        .padding(16)
        .glassCard()
    }

    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(personalityColor)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var roundUpHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Round-Ups")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(roundUpTransactions.count) total")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            if roundUpTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.title)
                        .foregroundStyle(Theme.textMuted)
                    Text("Add expense transactions\nand round-ups will appear here")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
            } else {
                ForEach(Array(roundUpTransactions.prefix(15).enumerated()), id: \.offset) { _, item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(personalityColor.opacity(0.12))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(personalityColor)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.0)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text(item.2, style: .relative)
                                .font(.caption)
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        Text("+$\(String(format: "%.2f", item.1))")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundStyle(Theme.success)
                    }
                    .padding(12)
                    .background(Theme.elevated.opacity(0.5), in: .rect(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .glassCard()
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

    private func syncRoundUps() {
        var newTotal: Double = 0
        for tx in transactions where tx.transactionType == .expense {
            let rounded = ceil(tx.amount)
            let diff = rounded - tx.amount
            if diff > 0.001 {
                newTotal += diff
            }
        }
        if abs(newTotal - challenge.roundUpTotal) > 0.001 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                challenge.roundUpTotal = newTotal
                challenge.totalSaved = newTotal
                coinDrop = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { coinDrop = false }
            }
        }
    }
}
