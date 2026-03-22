import SwiftUI
import SwiftData

struct AccountabilityBuddyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var buddies: [QuestBuddy]
    @Query private var playerProfiles: [PlayerProfile]
    @State private var showInviteSheet: Bool = false
    @State private var showCelebration: Bool = false
    @State private var celebrationQuest: String = ""
    @State private var celebrationEmoji: String = ""
    @State private var selectedReactionBuddy: QuestBuddy?

    private var player: PlayerProfile? { playerProfiles.first }
    private var activeBuddy: QuestBuddy? { buddies.first(where: { $0.isActive }) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                if let buddy = activeBuddy {
                    buddyDashboard(buddy)
                    recentActivity(buddy)
                    celebrateBuddySection(buddy)
                } else {
                    noBuddyState
                }
            }
            .padding(.vertical, 20)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Quest Buddy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showInviteSheet) {
            BuddyInviteSheet()
                .presentationDetents([.medium])
        }
        .overlay {
            if showCelebration {
                BuddyCelebrationOverlay(
                    emoji: celebrationEmoji,
                    questTitle: celebrationQuest,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3)) {
                            showCelebration = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }

    private var noBuddyState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 40)

            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 100, height: 100)

                Circle()
                    .stroke(Theme.accent.opacity(0.2), lineWidth: 2)
                    .frame(width: 100, height: 100)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }

            VStack(spacing: 8) {
                Text("Find a Quest Buddy")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Team up with a friend to stay accountable.\nCelebrate wins together — no shame, only hype.")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            VStack(alignment: .leading, spacing: 12) {
                buddyPerk(icon: "flame.fill", color: Color(hex: 0xFB923C), text: "See each other's quest streaks")
                buddyPerk(icon: "trophy.fill", color: Theme.gold, text: "Celebrate quest completions")
                buddyPerk(icon: "eye.slash.fill", color: Color(hex: 0x60A5FA), text: "No amounts or failed quests shared")
                buddyPerk(icon: "heart.fill", color: Color(hex: 0xF472B6), text: "Send reactions: confetti, fire, hearts")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.border, lineWidth: 0.5)
                    )
            )
            .padding(.horizontal, 20)

            Button {
                showInviteSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Invite a Buddy")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .buttonStyle(PressableButtonStyle())

            Button {
                addSimulatedBuddy()
            } label: {
                Text("Match me with someone")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.accent)
            }

            Spacer().frame(height: 40)
        }
    }

    private func buddyPerk(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
        }
    }

    private func buddyDashboard(_ buddy: QuestBuddy) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent.opacity(0.3), Theme.accent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Circle()
                        .stroke(Theme.accent.opacity(0.4), lineWidth: 2)
                        .frame(width: 56, height: 56)

                    Text(String(buddy.buddyName.prefix(2)).uppercased())
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(buddy.buddyName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                        Text("Buddied \(buddy.matchDate.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(Theme.textMuted)
                }

                Spacer()

                VStack(spacing: 2) {
                    Image(systemName: buddy.buddyQuestStreak > 0 ? "flame.fill" : "flame")
                        .font(.system(size: 20))
                        .foregroundStyle(buddy.buddyQuestStreak > 0 ? Color(hex: 0xFB923C) : Theme.textMuted)
                        .symbolEffect(.pulse, isActive: buddy.buddyQuestStreak >= 7)

                    Text("\(buddy.buddyQuestStreak)")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("streak")
                        .font(.system(size: 8))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            HStack(spacing: 12) {
                buddyStat(
                    icon: "checkmark.seal.fill",
                    value: "\(buddy.buddyWeeklyCompletions)",
                    label: "This Week",
                    color: Theme.accent
                )

                buddyStat(
                    icon: "flame.fill",
                    value: "\(buddy.buddyQuestStreak)d",
                    label: "Streak",
                    color: Color(hex: 0xFB923C)
                )

                let buddyZone = QuestZone(rawValue: buddy.buddyActiveZone) ?? .awakening
                buddyStat(
                    icon: buddyZone.sfSymbol,
                    value: buddyZone.rawValue.components(separatedBy: " ").last ?? "",
                    label: "Zone",
                    color: Color(hex: 0x60A5FA)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.border, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }

    private func buddyStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.elevated)
        )
    }

    private func recentActivity(_ buddy: QuestBuddy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.gold)
                Text("Buddy's Recent Wins")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
            }

            let recentWins = simulatedBuddyWins
            ForEach(recentWins, id: \.title) { win in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(win.color.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: win.icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(win.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(win.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(win.time)
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.textMuted)
                    }

                    Spacer()

                    if !win.reacted {
                        Button {
                            selectedReactionBuddy = buddy
                            celebrationQuest = win.title
                        } label: {
                            Text("React")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(Theme.accent.opacity(0.15))
                                )
                        }
                    } else {
                        Text(win.reaction)
                            .font(.system(size: 18))
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.elevated)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.border, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
        .sheet(item: $selectedReactionBuddy) { buddy in
            ReactionPickerSheet(
                questTitle: celebrationQuest,
                onReact: { emoji in
                    sendReaction(emoji: emoji, questTitle: celebrationQuest, buddy: buddy)
                    selectedReactionBuddy = nil
                }
            )
            .presentationDetents([.height(280)])
        }
    }

    private func celebrateBuddySection(_ buddy: QuestBuddy) -> some View {
        VStack(spacing: 12) {
            if !buddy.reactions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0xF472B6))
                        Text("Reactions Sent")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                    }

                    ForEach(buddy.reactions.suffix(5)) { reaction in
                        HStack(spacing: 10) {
                            Text(reaction.emoji)
                                .font(.system(size: 20))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("You reacted to \"\(reaction.questTitle)\"")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(1)
                                Text(reaction.sentAt.formatted(.relative(presentation: .named)))
                                    .font(.system(size: 9))
                                    .foregroundStyle(Theme.textMuted)
                            }

                            Spacer()
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Theme.border, lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 16)
            }

            Button {
                showInviteSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Invite Another Buddy")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.accent.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.accent.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 16)
        }
    }

    private func sendReaction(emoji: String, questTitle: String, buddy: QuestBuddy) {
        let reaction = BuddyReaction(emoji: emoji, questTitle: questTitle)
        var current = buddy.reactions
        current.append(reaction)
        buddy.reactions = current
        try? modelContext.save()

        celebrationEmoji = emoji
        celebrationQuest = questTitle
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showCelebration = true
        }

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func addSimulatedBuddy() {
        let name = CommunityContent.generateAnonymousName()
        let code = String(UUID().uuidString.prefix(8)).uppercased()
        let buddy = QuestBuddy(buddyName: name, inviteCode: code)
        modelContext.insert(buddy)
        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private var simulatedBuddyWins: [BuddyWin] {
        [
            BuddyWin(title: "Completed No-Spend Day", icon: "shield.checkered", color: Color(hex: 0x60A5FA), time: "2 hours ago", reacted: false, reaction: ""),
            BuddyWin(title: "Slay the Subscription Dragon", icon: "arrow.uturn.backward.circle.fill", color: Theme.accent, time: "Yesterday", reacted: true, reaction: "🔥"),
            BuddyWin(title: "Kitchen Warrior Streak", icon: "fork.knife", color: Theme.gold, time: "3 days ago", reacted: true, reaction: "🎉"),
        ]
    }
}

private struct BuddyWin {
    let title: String
    let icon: String
    let color: Color
    let time: String
    let reacted: Bool
    let reaction: String
}

struct BuddyInviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inviteCode: String = String(UUID().uuidString.prefix(8)).uppercased()
    @State private var copied: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                ZStack {
                    Circle()
                        .fill(Theme.accent.opacity(0.1))
                        .frame(width: 72, height: 72)
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Theme.accent)
                }

                VStack(spacing: 6) {
                    Text("Your Invite Code")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(inviteCode)
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundStyle(Theme.accent)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.elevated)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                                )
                        )

                    Text("Share this code with a friend")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textMuted)
                }

                HStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = inviteCode
                        copied = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            copied = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 13, weight: .bold))
                            Text(copied ? "Copied!" : "Copy")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(copied ? Theme.accent : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Theme.elevated)
                        )
                    }

                    let shareText = "Join me on Splurj! Use buddy code: \(inviteCode) to team up on financial quests 💰"
                    ShareLink(item: shareText) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13, weight: .bold))
                            Text("Share")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.accent, in: .rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Invite Buddy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ReactionPickerSheet: View {
    let questTitle: String
    let onReact: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    private let reactions: [(emoji: String, label: String)] = [
        ("🎉", "Confetti"),
        ("🔥", "Fire"),
        ("❤️", "Heart"),
        ("💪", "Strong"),
        ("⭐️", "Star"),
        ("👏", "Clap"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("React to")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textMuted)
                Text(questTitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(reactions, id: \.emoji) { reaction in
                        Button {
                            onReact(reaction.emoji)
                        } label: {
                            VStack(spacing: 6) {
                                Text(reaction.emoji)
                                    .font(.system(size: 36))
                                Text(reaction.label)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.elevated)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 16)
            .background(Theme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }
}

struct BuddyCelebrationOverlay: View {
    let emoji: String
    let questTitle: String
    let onDismiss: () -> Void

    @State private var emojiScale: CGFloat = 0.3
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 72))
                    .scaleEffect(emojiScale)

                VStack(spacing: 4) {
                    Text("Reaction Sent!")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your buddy will see your \(emoji) for")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)

                    Text("\"\(questTitle)\"")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .lineLimit(1)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                emojiScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                textOpacity = 1.0
            }

            Task {
                try? await Task.sleep(for: .seconds(2))
                onDismiss()
            }
        }
    }
}
