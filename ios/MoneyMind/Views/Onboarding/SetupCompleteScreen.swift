import SwiftUI
import SwiftData
import UserNotifications

struct SetupCompleteScreen: View {
    let personality: MoneyPersonality
    let userPath: UserPath
    let currencyCode: String
    let currencySymbol: String
    let savedAmount: Double
    let modelContext: ModelContext
    let onComplete: () -> Void

    @State private var name: String = ""
    @State private var notificationsEnabled = false
    @State private var notificationRequested = false
    @State private var appeared = false
    @State private var confettiTriggered = false
    @FocusState private var nameFocused: Bool

    private var personalityEmoji: String {
        switch personality {
        case .saver: "🌿"
        case .builder: "📈"
        case .hustler: "🔥"
        case .minimalist: "✨"
        case .generous: "💛"
        }
    }

    private var personalityName: String {
        personality.rawValue.replacingOccurrences(of: "The ", with: "")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 32)

                ZStack {
                    confettiBurst

                    VStack(spacing: 8) {
                        Text("You're all set, \(personalityEmoji)!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)

                        Text("Here's your Splurj profile")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                summaryCard

                VStack(alignment: .leading, spacing: 12) {
                    Text("What should we call you?")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    TextField("Your name", text: $name)
                        .font(.body)
                        .padding(16)
                        .background(Theme.elevated, in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.border, lineWidth: 0.5)
                        )
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.accent)
                        .focused($nameFocused)
                }
                .padding(.horizontal, 24)

                notificationCard
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Button {
                        saveAndComplete()
                    } label: {
                        Text("Start Using Splurj")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                !name.isEmpty
                                    ? AnyShapeStyle(Theme.accentGradient)
                                    : AnyShapeStyle(Color.gray.opacity(0.3)),
                                in: .rect(cornerRadius: 14)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(name.isEmpty)
                    .sensoryFeedback(.success, trigger: !name.isEmpty)

                    Text("Everything is free for 3 days. Explore everything.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .multilineTextAlignment(.center)

                    Button {
                        onComplete()
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
            confettiTriggered = true
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 14) {
            summaryRow(label: "Path", value: "\(userPath.emoji) \(userPath.displayName)")
            Divider().overlay(Theme.divider)
            summaryRow(label: "Personality", value: "\(personalityEmoji) \(personalityName)")
            Divider().overlay(Theme.divider)
            summaryRow(label: "Currency", value: "\(currencySymbol) \(currencyCode)")
            if savedAmount > 0 {
                Divider().overlay(Theme.divider)
                summaryRow(label: "First save", value: "\(currencySymbol)\(Int(savedAmount))")
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 16)
        .padding(.horizontal, 24)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.15), value: appeared)
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var notificationCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 44, height: 44)
                    .background(Theme.accent.opacity(0.12), in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Get a nudge when it matters")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text(userPath.notificationBenefit)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }

                Spacer()
            }

            if !notificationRequested {
                Button {
                    requestNotifications()
                } label: {
                    Text("Enable Smart Nudges")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent, in: .rect(cornerRadius: 10))
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(notificationsEnabled ? Theme.accent : Theme.textSecondary)
                    Text(notificationsEnabled ? "Smart Nudges enabled" : "Notifications not allowed")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(notificationsEnabled ? Theme.accent : Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Text("You can change this anytime in Settings")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(16)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.25), value: appeared)
    }

    @ViewBuilder
    private var confettiBurst: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                let angle = Double(i) * (360.0 / 12.0)
                let rad = angle * .pi / 180
                let distance: CGFloat = confettiTriggered ? CGFloat.random(in: 40...70) : 0
                let colors: [Color] = [Theme.accent, Theme.gold, Theme.accent.opacity(0.7)]

                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: CGFloat.random(in: 4...7), height: CGFloat.random(in: 4...7))
                    .offset(
                        x: cos(rad) * distance,
                        y: sin(rad) * distance
                    )
                    .opacity(confettiTriggered ? 0 : 1)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.5).delay(Double(i) * 0.02),
                        value: confettiTriggered
                    )
            }
        }
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            Task { @MainActor in
                notificationsEnabled = granted
                notificationRequested = true
            }
        }
    }

    private func saveAndComplete() {
        let profile = UserProfile(
            name: name,
            userPath: userPath,
            currencyCode: currencyCode,
            currencySymbol: currencySymbol
        )
        profile.notificationsEnabled = notificationsEnabled
        profile.defaultCurrency = currencyCode
        modelContext.insert(profile)
        onComplete()
    }
}
