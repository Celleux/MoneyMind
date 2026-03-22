import SwiftUI
import SwiftData

struct WalletView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \ImpulseLog.date, order: .reverse) private var impulseLogs: [ImpulseLog]
    @State private var vm = WalletViewModel()
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }
    private var gentle: Bool { profile?.gentleViewMode ?? false }

    private var effectiveTotal: Double {
        vm.effectiveTotal(profile?.totalSaved ?? 0, phantomApplied: profile?.phantomProgressApplied ?? false)
    }

    private var todaySaved: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return impulseLogs.filter { $0.resisted && $0.date >= today }.reduce(0) { $0 + $1.amount }
    }

    private var weekSaved: Double {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= weekAgo }.reduce(0) { $0 + $1.amount }
    }

    private var monthSaved: Double {
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return impulseLogs.filter { $0.resisted && $0.date >= monthAgo }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        heroCounterCard
                        walletVisualization
                        statsRow
                        impulseCostCalculator
                        weeklyChart
                        recentTransactions
                        projectionCard
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)

                floatingActions
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Wallet")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $vm.showLogWin) {
                WalletLogWinSheet(onSaved: { amount in
                    vm.celebrationAmount = amount
                    vm.showCelebration = true
                    let oldTotal = profile?.totalSaved ?? 0
                    vm.checkMilestone(oldTotal: oldTotal, newTotal: oldTotal + amount)
                })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
            }
            .sheet(isPresented: $vm.showAutopsy) {
                SpendingAutopsySheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
            }
            .overlay {
                if vm.showCelebration {
                    CelebrationOverlay(amount: vm.celebrationAmount) {
                        vm.showCelebration = false
                    }
                }
            }
            .overlay {
                if vm.showMilestone {
                    MilestoneOverlay(amount: vm.milestoneValue) {
                        vm.showMilestone = false
                    }
                }
            }
            .onAppear {
                applyPhantomProgress()
            }
        }
    }

    private func applyPhantomProgress() {
        guard let profile, !profile.phantomProgressApplied, profile.totalSaved == 0 else { return }
        profile.totalSaved = 2.0
        profile.phantomProgressApplied = true
    }

    // MARK: - Hero Counter

    private var heroCounterCard: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "wallet.bifold.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.accentGreen)
                Text("Total Saved")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                if let progress = vm.milestoneProgress(for: effectiveTotal),
                   let next = vm.nextMilestone(for: effectiveTotal) {
                    goalGradientBadge(progress: progress, milestone: next)
                }
            }

            if gentle && !vm.revealExact {
                Text(vm.displayAmount(effectiveTotal, gentle: true))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture { vm.revealExact = true }
                    .accessibilityLabel("Total saved approximately \(Int(effectiveTotal)) dollars")
            } else {
                Text(effectiveTotal, format: .currency(code: "USD"))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentTransition(.numericText(value: effectiveTotal))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: effectiveTotal)
                    .sensoryFeedback(.impact(weight: .medium), trigger: effectiveTotal)
                    .accessibilityLabel("Total saved \(effectiveTotal, format: .currency(code: "USD"))")
            }

            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(Theme.teal)
                let hours = vm.workHours(for: effectiveTotal, rate: profile?.hourlyRate ?? 20)
                Text("That's \(hours, specifier: "%.1f") hours of your work")
                    .font(.caption)
                    .foregroundStyle(Theme.teal)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Theme.accentGreen.opacity(0.12), Theme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.accentGreen.opacity(0.2), lineWidth: 1)
        )
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.05), value: vm.appeared)
        .onAppear { vm.appeared = true }
    }

    private func goalGradientBadge(progress: Double, milestone: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "flag.checkered")
                .font(.caption2)
            Text("$\(Int(milestone))")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(Theme.gold)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.gold.opacity(0.15), in: .capsule)
        .overlay(
            Capsule()
                .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 1)
        )
        .symbolEffect(.pulse, options: .repeating, isActive: true)
    }

    // MARK: - Wallet Visualization

    private var walletVisualization: some View {
        let level = vm.currentLevel(for: effectiveTotal)
        let progress = vm.levelProgress(for: effectiveTotal)

        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.accentGreen.opacity(0.06))
                    .frame(width: 100, height: 100)

                Circle()
                    .strokeBorder(Theme.accentGreen.opacity(0.15), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Image(systemName: level.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.accentGradient)
                    .symbolEffect(.breathe, options: .repeating, isActive: vm.appeared)

                SparkleParticlesView()
                    .frame(width: 120, height: 120)
                    .allowsHitTesting(false)
            }

            Text(level.name)
                .font(Theme.headingFont(.headline))
                .foregroundStyle(Theme.textPrimary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.cardSurface)
                        .frame(height: 6)
                    Capsule()
                        .fill(Theme.accentGradient)
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 8)
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.08), value: vm.appeared)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            WalletStatPill(label: "Today", amount: todaySaved, color: Theme.accentGreen, gentle: gentle, revealExact: vm.revealExact)
            WalletStatPill(label: "This Week", amount: weekSaved, color: Theme.teal, gentle: gentle, revealExact: vm.revealExact)
            WalletStatPill(label: "This Month", amount: monthSaved, color: Theme.gold, gentle: gentle, revealExact: vm.revealExact)
        }
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.1), value: vm.appeared)
    }

    // MARK: - Impulse Cost Calculator

    private var impulseCostCalculator: some View {
        let totalResisted = vm.totalResisted(from: impulseLogs)
        let totalGaveIn = vm.totalGaveIn(from: impulseLogs)
        let totalImpact = totalResisted + totalGaveIn

        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(Theme.gold)
                Text("Impulse Cost Calculator")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }

            HStack(spacing: 12) {
                VStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.emergency)
                    Text("Without\nMoneyMind")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text(gentle && !vm.revealExact ? vm.displayAmountShort(totalImpact, gentle: true) : "$\(Int(totalImpact))")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.emergency)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.emergency.opacity(0.08), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Theme.emergency.opacity(0.15), lineWidth: 1)
                )

                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accentGreen)
                    Text("With\nMoneyMind")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text(gentle && !vm.revealExact ? vm.displayAmountShort(totalResisted, gentle: true) : "$\(Int(totalResisted))")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.accentGreen)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accentGreen.opacity(0.08), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Theme.accentGreen.opacity(0.15), lineWidth: 1)
                )
            }

            if totalImpact > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                    Text("Total Impact:")
                        .font(.subheadline)
                    Text("$\(Int(totalImpact))")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                }
                .foregroundStyle(Theme.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Theme.gold.opacity(0.08), in: .rect(cornerRadius: 10))
            }
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.gold.opacity(0.1), lineWidth: 1)
        )
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.12), value: vm.appeared)
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        let dailyData = vm.dailySavings(from: impulseLogs)
        let labels = vm.dayLabels()
        let maxVal = dailyData.max() ?? 1

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Theme.accentGreen)
                Text("This Week")
                    .font(Theme.headingFont(.subheadline))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("$\(Int(weekSaved)) saved")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    VStack(spacing: 4) {
                        let height = maxVal > 0 ? CGFloat(dailyData[i] / maxVal) * 48 : 0
                        RoundedRectangle(cornerRadius: 3)
                            .fill(i == 6 ? Theme.accentGreen : Theme.accentGreen.opacity(0.5))
                            .frame(width: 20, height: max(4, height))
                            .shadow(color: i == 6 ? Theme.accentGreen.opacity(0.4) : .clear, radius: 4)

                        Text(labels[i])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(i == 6 ? Theme.textPrimary : Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 68)
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.14), value: vm.appeared)
    }

    // MARK: - Recent Transactions

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent Activity")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                if !impulseLogs.isEmpty {
                    Text("\(impulseLogs.count) total")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            if impulseLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(Theme.gold.opacity(0.4))
                    Text("No activity yet")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    Text("Tap the green button to log your first resist!")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
            } else {
                VStack(spacing: 2) {
                    ForEach(impulseLogs.prefix(10)) { log in
                        WalletTransactionRow(log: log, gentle: gentle, revealExact: vm.revealExact)
                    }
                }
                .clipShape(.rect(cornerRadius: 16))
            }
        }
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.16), value: vm.appeared)
    }

    // MARK: - Projection

    private var projectionCard: some View {
        let daily = profile?.dailyImpulseAmount ?? 25
        let yearProjection = daily * 365

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Theme.teal)
                Text("1-Year Projection")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
            }

            Text(yearProjection, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accentGradient)

            Text("if you save $\(daily, specifier: "%.0f")/day for a full year")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.teal.opacity(0.1), lineWidth: 1)
        )
        .opacity(vm.appeared ? 1 : 0)
        .offset(y: vm.appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.18), value: vm.appeared)
    }

    // MARK: - Floating Actions

    private var floatingActions: some View {
        VStack(spacing: 10) {
            Button {
                vm.showLogWin = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.accentGreen)
                        .frame(width: 60, height: 60)
                        .shadow(color: Theme.accentGreen.opacity(0.4), radius: 12, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Theme.background)
                }
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: vm.showLogWin)
            .accessibilityLabel("Log a win")
            .accessibilityHint("Record an impulse you resisted")

            Button {
                vm.showAutopsy = true
            } label: {
                Text("I gave in")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.cardSurface, in: .capsule)
                    .overlay(
                        Capsule()
                            .strokeBorder(Theme.textSecondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("I gave in")
            .accessibilityHint("Log a spending slip for reflection")
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Supporting Views

private struct WalletStatPill: View {
    let label: String
    let amount: Double
    let color: Color
    let gentle: Bool
    let revealExact: Bool

    var body: some View {
        VStack(spacing: 6) {
            if gentle && !revealExact {
                Text("~$\(Int((amount / 10).rounded() * 10))")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text(amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 14))
    }
}

private struct WalletTransactionRow: View {
    let log: ImpulseLog
    let gentle: Bool
    let revealExact: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(log.resisted ? Theme.accentGreen.opacity(0.15) : Theme.emergency.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: log.resisted ? "checkmark" : "arrow.uturn.backward")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(log.resisted ? Theme.accentGreen : Theme.emergency)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(log.note.isEmpty ? (log.resisted ? "Impulse resisted" : "Gave in") : log.note)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(log.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)

                    if !log.emotionalTrigger.isEmpty {
                        Text(log.emotionalTrigger)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Theme.teal)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.teal.opacity(0.12), in: .capsule)
                    }
                }
            }

            Spacer()

            if gentle && !revealExact {
                Text(log.resisted ? "+~$\(Int((log.amount / 10).rounded() * 10))" : "-~$\(Int((log.amount / 10).rounded() * 10))")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(log.resisted ? Theme.accentGreen : Theme.emergency)
            } else {
                Text(log.resisted ? "+$\(log.amount, specifier: "%.0f")" : "-$\(log.amount, specifier: "%.0f")")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(log.resisted ? Theme.accentGreen : Theme.emergency)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.cardSurface)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Sparkle Particles

struct SparkleParticlesView: View {
    @State private var particles: [SparkleParticle] = (0..<8).map { _ in SparkleParticle() }
    @State private var animating = false

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let x = size.width * particle.x + (animating ? CGFloat.random(in: -4...4) : 0)
                let y = size.height * particle.y + (animating ? CGFloat.random(in: -4...4) : 0)
                let opacity = animating ? particle.opacity : particle.opacity * 0.5
                context.opacity = opacity
                let symbol = context.resolve(Image(systemName: "sparkle"))
                let sz = particle.size
                context.draw(symbol, in: CGRect(x: x - sz/2, y: y - sz/2, width: sz, height: sz))
            }
        }
        .foregroundStyle(Theme.gold)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animating = true
            }
        }
    }
}

private struct SparkleParticle {
    let x: CGFloat = .random(in: 0.1...0.9)
    let y: CGFloat = .random(in: 0.1...0.9)
    let opacity: Double = .random(in: 0.3...0.8)
    let size: CGFloat = .random(in: 6...12)
}

// MARK: - Celebration Overlay

struct CelebrationOverlay: View {
    let amount: Double
    let onDismiss: () -> Void
    @State private var show = false
    @State private var coinY: CGFloat = -100
    @State private var coinScale: CGFloat = 1.2
    @State private var confettiTrigger: Int = 0

    var body: some View {
        ZStack {
            Color.black.opacity(show ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 20) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.gold)
                    .scaleEffect(coinScale)
                    .offset(y: coinY)

                Text("+$\(Int(amount))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accentGreen)

                Text("saved!")
                    .font(.title3)
                    .foregroundStyle(Theme.textPrimary)
            }
            .scaleEffect(show ? 1 : 0.5)
            .opacity(show ? 1 : 0)

            ConfettiView(trigger: confettiTrigger)
                .allowsHitTesting(false)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                show = true
                coinY = 0
                coinScale = 1.0
            }
            confettiTrigger += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
        .sensoryFeedback(.success, trigger: show)
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            show = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Milestone Overlay

struct MilestoneOverlay: View {
    let amount: Double
    let onDismiss: () -> Void
    @State private var show = false
    @State private var flashOpacity: Double = 0
    @State private var showMilestoneShare = false

    var body: some View {
        ZStack {
            Color.white.opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            Color.black.opacity(show ? 0.5 : 0)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.goldGradient)
                    .symbolEffect(.bounce, value: show)

                Text("MILESTONE!")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .tracking(4)

                Text("$\(Int(amount))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)

                Text("You've reached a new level!")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                HStack(spacing: 12) {
                    Button {
                        showMilestoneShare = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                            Text("Share")
                                .font(.headline)
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.goldGradient, in: .capsule)
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        dismiss()
                    } label: {
                        Text("Later")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.cardSurface, in: .capsule)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
            }
            .scaleEffect(show ? 1 : 0.3)
            .opacity(show ? 1 : 0)

            ConfettiView(trigger: show ? 1 : 0)
                .allowsHitTesting(false)
        }
        .sheet(isPresented: $showMilestoneShare, onDismiss: { dismiss() }) {
            MilestoneShareSheet(milestoneAmount: amount)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) {
                flashOpacity = 0.6
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeOut(duration: 0.3)) {
                    flashOpacity = 0
                }
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                show = true
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: show)
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            show = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Confetti

struct ConfettiView: View {
    let trigger: Int
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        Canvas { context, size in
            for p in particles {
                context.opacity = p.opacity
                context.fill(
                    Path(ellipseIn: CGRect(x: p.x * size.width - 4, y: p.y * size.height - 4, width: 8, height: 8)),
                    with: .color(p.color)
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, _ in
            spawnConfetti()
        }
    }

    private func spawnConfetti() {
        particles = (0..<40).map { _ in
            ConfettiParticle(
                x: .random(in: 0.1...0.9),
                y: -0.1,
                opacity: 1,
                color: [Theme.accentGreen, Theme.gold, Theme.teal, Theme.emergency, .white].randomElement()!
            )
        }
        withAnimation(.easeOut(duration: 1.5)) {
            particles = particles.map { p in
                ConfettiParticle(
                    x: p.x + .random(in: -0.2...0.2),
                    y: .random(in: 0.6...1.2),
                    opacity: 0,
                    color: p.color
                )
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var color: Color
}
