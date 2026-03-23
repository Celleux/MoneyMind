import SwiftUI
import SwiftData
import UserNotifications

struct LaunchScreenView: View {
    let dna: FinancialDNA
    let modelContext: ModelContext
    let onComplete: () -> Void

    @State private var name: String = ""
    @State private var notificationsEnabled = false
    @State private var notificationRequested = false
    @State private var appeared = false
    @FocusState private var nameFocused: Bool

    private var archetype: FinancialArchetype { dna.primaryArchetype }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                VStack(spacing: 8) {
                    Text("Welcome,")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)

                    TextField("Your name", text: $name)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .tint(Theme.accent)
                        .focused($nameFocused)
                        .padding(.horizontal, 40)

                    Rectangle()
                        .fill(Theme.accent.opacity(name.isEmpty ? 0.3 : 0.6))
                        .frame(width: 160, height: 2)
                        .animation(.easeOut(duration: 0.2), value: name)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)

                HStack(spacing: 12) {
                    Image(systemName: archetype.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(archetype.color)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(archetype.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(archetype.tagline)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(archetype.color)
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        axisDot(value: dna.spendingAxis, color: Color(hex: 0x34D399))
                        axisDot(value: dna.emotionalAxis, color: Color(hex: 0x60A5FA))
                        axisDot(value: dna.riskAxis, color: Color(hex: 0xFB923C))
                        axisDot(value: dna.socialAxis, color: Color(hex: 0xF472B6))
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.spring(response: 0.5).delay(0.15), value: appeared)

                HStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 40, height: 40)
                        .background(Theme.accent.opacity(0.12), in: .rect(cornerRadius: 10))

                    Text("Your first quest is waiting.")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(16)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 15)
                .animation(.spring(response: 0.5).delay(0.25), value: appeared)

                notificationCard
                    .padding(.horizontal, 24)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)
                    .animation(.spring(response: 0.5).delay(0.35), value: appeared)

                Spacer().frame(height: 8)

                Button {
                    saveAndComplete()
                } label: {
                    HStack(spacing: 8) {
                        Text("Enter Splurj")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        !name.isEmpty
                            ? AnyShapeStyle(Theme.accentGradient)
                            : AnyShapeStyle(Color.gray.opacity(0.3)),
                        in: .rect(cornerRadius: 14)
                    )
                    .shadow(color: !name.isEmpty ? Theme.accent.opacity(0.4) : .clear, radius: 16, y: 6)
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(name.isEmpty)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: appeared)

                Button {
                    onComplete()
                } label: {
                    Text("Skip for now")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.top, 4)
                .padding(.bottom, 48)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }

    private func axisDot(value: Double, color: Color) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.elevated)
                .frame(width: 4, height: 20)

            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 20 * max(0.1, value))
        }
    }

    private var notificationCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 40, height: 40)
                    .background(Theme.accent.opacity(0.12), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Remind me to complete quests")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Daily quest reminders & streak alerts")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()
            }

            if !notificationRequested {
                Button {
                    requestNotifications()
                } label: {
                    Text("Enable Reminders")
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
                    Text(notificationsEnabled ? "Reminders enabled" : "Not now — you can enable later")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(notificationsEnabled ? Theme.accent : Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
        }
        .padding(16)
        .glassCard()
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
        let profile = UserProfile(name: name)
        profile.notificationsEnabled = notificationsEnabled
        modelContext.insert(profile)

        let result = FinancialDNAResult(
            dna: dna,
            cardSortAnswers: [],
            triggerRatings: [:],
            memoryAnswers: [],
            riskScore: dna.riskAxis
        )
        modelContext.insert(result)
        try? modelContext.save()

        onComplete()
    }
}
