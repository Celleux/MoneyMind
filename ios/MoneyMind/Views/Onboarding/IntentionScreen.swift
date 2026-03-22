import SwiftUI
import SwiftData
import UserNotifications

struct IntentionScreen: View {
    let personality: MoneyPersonality
    let modelContext: ModelContext
    let onComplete: () -> Void

    @State private var selectedIntention: String = ""
    @State private var customIntention: String = ""
    @State private var name: String = ""
    @State private var appeared = false
    @State private var notificationsEnabled = false
    @State private var notificationRequested = false
    @FocusState private var nameFocused: Bool

    private let prefilledOptions = [
        "Take 3 deep breaths and wait 10 minutes",
        "Open Splurj and log the urge",
        "Call my accountability partner"
    ]

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
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("Almost there, \(personalityEmoji)")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Set your intention for when urges hit")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 40)
                .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 12) {
                    Text("What should we call you?")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    TextField("Your name", text: $name)
                        .font(.body)
                        .padding(16)
                        .background(Theme.cardSurface, in: .rect(cornerRadius: 8))
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.accentGreen)
                        .focused($nameFocused)
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    Text("\"If I feel the urge to spend impulsively, I will...\"")
                        .font(.subheadline.italic())
                        .foregroundStyle(Theme.teal)

                    VStack(spacing: 10) {
                        ForEach(prefilledOptions, id: \.self) { option in
                            let isSelected = selectedIntention == option
                            Button {
                                selectedIntention = option
                                customIntention = ""
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isSelected ? Theme.accentGreen : Theme.textSecondary)

                                    Text(option)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textPrimary)
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    isSelected ? Theme.accentGreen.opacity(0.1) : Theme.cardSurface,
                                    in: .rect(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Theme.accentGreen.opacity(0.4) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                            .sensoryFeedback(.selection, trigger: isSelected)
                        }

                        TextField("Or write your own...", text: $customIntention)
                            .font(.subheadline)
                            .padding(14)
                            .background(Theme.cardSurface, in: .rect(cornerRadius: 12))
                            .foregroundStyle(Theme.textPrimary)
                            .tint(Theme.accentGreen)
                            .onChange(of: customIntention) { _, newValue in
                                if !newValue.isEmpty { selectedIntention = "" }
                            }
                    }
                }
                .padding(.horizontal, 24)

                notificationCard
                    .padding(.horizontal, 24)

                VStack(spacing: 12) {
                    Button {
                        saveAndComplete()
                    } label: {
                        Text("Start My Splurj Journey")
                            .font(.headline)
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                canContinue
                                    ? AnyShapeStyle(Theme.accentGradient)
                                    : AnyShapeStyle(Color.gray.opacity(0.3)),
                                in: .rect(cornerRadius: 12)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(!canContinue)
                    .sensoryFeedback(.success, trigger: canContinue)

                    Text("Free forever. Premium unlocks deeper tools.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)

                    Button {
                        onComplete()
                    } label: {
                        Text("Skip for now")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
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

    private var notificationCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.accentGreen)
                    .frame(width: 44, height: 44)
                    .background(Theme.accentGreen.opacity(0.12), in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Get a gentle nudge when your spending patterns spike")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    Text("\(personalityName)s who enable notifications save 34% more")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(personality.color)
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
                        .background(Theme.accentGreen, in: .rect(cornerRadius: 10))
                }
                .buttonStyle(PressableButtonStyle())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: notificationsEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(notificationsEnabled ? Theme.accentGreen : Theme.textSecondary)
                    Text(notificationsEnabled ? "Smart Nudges enabled" : "Notifications not allowed")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(notificationsEnabled ? Theme.accentGreen : Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }

            Text("You can change this anytime in Settings")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.accentGreen.opacity(0.15), lineWidth: 0.5)
        )
    }

    private var canContinue: Bool {
        !name.isEmpty && (!selectedIntention.isEmpty || !customIntention.isEmpty)
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

        let intentionText = customIntention.isEmpty ? selectedIntention : customIntention
        let intention = ImplementationIntention(intention: intentionText)
        modelContext.insert(intention)

        onComplete()
    }
}
