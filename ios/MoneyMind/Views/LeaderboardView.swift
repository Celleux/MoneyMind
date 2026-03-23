import SwiftUI
import SwiftData

nonisolated enum LeaderboardScope: String, CaseIterable, Sendable {
    case friends = "Friends"
    case global = "Global"
    case city = "City"
}

nonisolated enum LeaderboardTimeframe: String, CaseIterable, Sendable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case allTime = "All-Time"
}

nonisolated struct LeaderboardEntry: Identifiable, Sendable {
    let id: String
    let rank: Int
    let username: String
    let avatarIcon: String
    let level: Int
    let weeklyScore: Double
    let streak: Int
    let isCurrentUser: Bool
}

struct LeaderboardView: View {
    @Query private var profiles: [UserProfile]
    @Query private var playerProfiles: [PlayerProfile]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var scope: LeaderboardScope = .friends
    @State private var timeframe: LeaderboardTimeframe = .weekly
    @State private var entries: [LeaderboardEntry] = []
    @State private var appeared: Bool = false
    @State private var showInviteSheet: Bool = false

    private var currentUserName: String {
        profiles.first?.name ?? "You"
    }

    private var currentUserLevel: Int {
        playerProfiles.first?.level ?? 1
    }

    private var currentUserStreak: Int {
        playerProfiles.first?.questStreak ?? 0
    }

    private var currentUserSaved: Double {
        profiles.first?.totalSaved ?? 0
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                scopePicker
                timeframePicker
                podiumSection
                rankingsList
                inviteButton
            }
            .padding(.bottom, 32)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            generateMockData()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                appeared = true
            }
        }
        .onChange(of: scope) { _, _ in regenerateData() }
        .onChange(of: timeframe) { _, _ in regenerateData() }
        .sheet(isPresented: $showInviteSheet) {
            inviteSheet
        }
    }

    // MARK: - Scope Picker

    private var scopePicker: some View {
        Picker("Scope", selection: $scope) {
            ForEach(LeaderboardScope.allCases, id: \.self) { s in
                Text(s.rawValue).tag(s)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Timeframe Picker

    private var timeframePicker: some View {
        HStack(spacing: 0) {
            ForEach(LeaderboardTimeframe.allCases, id: \.self) { tf in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        timeframe = tf
                    }
                } label: {
                    Text(tf.rawValue)
                        .font(.system(size: 13, weight: timeframe == tf ? .bold : .medium, design: .rounded))
                        .foregroundStyle(timeframe == tf ? .white : Theme.textMuted)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            timeframe == tf
                            ? AnyShapeStyle(Theme.accentGradient)
                            : AnyShapeStyle(Color.clear),
                            in: .capsule
                        )
                }
                .sensoryFeedback(.selection, trigger: timeframe)
            }
        }
        .padding(4)
        .background(Theme.surface, in: .capsule)
        .overlay(Capsule().strokeBorder(Theme.glassBorder, lineWidth: 0.5))
        .padding(.horizontal, 20)
    }

    // MARK: - Podium

    private var podiumSection: some View {
        let top3 = Array(entries.prefix(3))
        return VStack(spacing: 0) {
            if top3.count >= 3 {
                HStack(alignment: .bottom, spacing: 8) {
                    podiumCard(entry: top3[1], medal: "2", color: Color(hex: 0xC0C0C0), height: 130)
                    podiumCard(entry: top3[0], medal: "1", color: Theme.neonGold, height: 160)
                    podiumCard(entry: top3[2], medal: "3", color: Color(hex: 0xCD7F32), height: 110)
                }
                .padding(.horizontal, 16)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            }
        }
    }

    private func podiumCard(entry: LeaderboardEntry, medal: String, color: Color, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .shadow(color: color.opacity(0.3), radius: 8)

                Image(systemName: entry.avatarIcon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)

                if entry.isCurrentUser {
                    Circle()
                        .strokeBorder(Theme.accent, lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }

            Text(entry.username)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.isCurrentUser ? Theme.accent : .white)
                .lineLimit(1)

            Text(formattedScore(entry.weeklyScore))
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.orange)
                Text("\(entry.streak)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.textSecondary)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: height * 0.35)

                Text(medal)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .glassCard(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [color.opacity(0.4), color.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(medal), \(entry.username), saved \(formattedScore(entry.weeklyScore)), \(entry.streak) day streak")
    }

    // MARK: - Rankings List

    private var rankingsList: some View {
        VStack(spacing: 0) {
            if entries.count > 3 {
                ForEach(Array(entries.dropFirst(3).enumerated()), id: \.element.id) { index, entry in
                    rankRow(entry: entry)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.04),
                            value: appeared
                        )

                    if index < entries.count - 4 {
                        Rectangle()
                            .fill(Theme.divider)
                            .frame(height: 0.5)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .background(Theme.surface.opacity(0.5), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.glassBorder, lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }

    private func rankRow(entry: LeaderboardEntry) -> some View {
        HStack(spacing: 12) {
            Text("\(entry.rank)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.textMuted)
                .frame(width: 28, alignment: .center)

            ZStack {
                Circle()
                    .fill(entry.isCurrentUser ? Theme.accent.opacity(0.15) : Theme.elevated)
                    .frame(width: 36, height: 36)

                Image(systemName: entry.avatarIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(entry.isCurrentUser ? Theme.accent : Theme.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(entry.username)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(entry.isCurrentUser ? Theme.accent : .white)
                        .lineLimit(1)

                    Text("Lv.\(entry.level)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                }

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.orange)
                    Text("\(entry.streak)d")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                }
            }

            Spacer()

            Text(formattedScore(entry.weeklyScore))
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            entry.isCurrentUser
            ? AnyShapeStyle(Theme.accent.opacity(0.06))
            : AnyShapeStyle(Color.clear)
        )
        .overlay {
            if entry.isCurrentUser {
                Rectangle()
                    .strokeBorder(Theme.accent.opacity(0.2), lineWidth: 0.5)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rank \(entry.rank), \(entry.username), level \(entry.level), saved \(formattedScore(entry.weeklyScore)), \(entry.streak) day streak")
    }

    // MARK: - Invite Button

    private var inviteButton: some View {
        Button {
            showInviteSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Invite Friends to Compete")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
            .shadow(color: Theme.accent.opacity(0.3), radius: 12, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, 20)
        .sensoryFeedback(.impact(weight: .medium), trigger: showInviteSheet)
    }

    private var inviteSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.neonGold)

                Text("Challenge Your Friends")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Compete on the savings leaderboard.\nSee who can save the most each week!")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let code = profiles.first?.referralCode {
                ShareLink(
                    item: "I challenge you to beat my savings score on Splurj! Join with my code: \(code)\nsplurj.app/join?ref=\(code)"
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Invite Link")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
                }
                .buttonStyle(PressableButtonStyle())
            }

            Button("Done") {
                showInviteSheet = false
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(Theme.textSecondary)
        }
        .padding(24)
        .padding(.top, 16)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(Theme.background)
    }

    // MARK: - Data Generation

    // TODO: Replace with backend API
    private func generateMockData() {
        guard entries.isEmpty else { return }
        entries = buildEntries()
    }

    private func regenerateData() {
        appeared = false
        entries = buildEntries()
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            appeared = true
        }
    }

    private func buildEntries() -> [LeaderboardEntry] {
        let names = [
            "Sarah K.", "Mike T.", "Emma L.", "Alex R.", "Jordan P.",
            "Taylor S.", "Morgan W.", "Casey H.", "Riley D.", "Quinn B.",
            "Drew M.", "Avery N.", "Parker J.", "Cameron F.", "Dakota V.",
            "Skyler G.", "Reese C.", "Finley A.", "Harper Z.", "Rowan E."
        ]
        let icons = [
            "person.fill", "figure.walk", "figure.run",
            "bolt.fill", "star.fill", "heart.fill",
            "leaf.fill", "flame.fill", "sparkles",
            "crown.fill"
        ]

        let multiplier: Double = {
            switch timeframe {
            case .weekly: return 1.0
            case .monthly: return 4.2
            case .allTime: return 26.0
            }
        }()

        let scopeSeed: Int = {
            switch scope {
            case .friends: return 42
            case .global: return 77
            case .city: return 19
            }
        }()

        var rng = SplitMix64(seed: UInt64(scopeSeed + timeframe.hashValue))
        let userPosition = Int(rng.next() % 11) + 5

        var result: [LeaderboardEntry] = []

        for i in 0..<20 {
            let isUser = (i == userPosition - 1)
            let baseScore = Double(200 - i * 8) + Double(rng.next() % 40) - 20
            let score = max(10, baseScore * multiplier)

            result.append(LeaderboardEntry(
                id: isUser ? "current_user" : "user_\(scopeSeed)_\(i)",
                rank: i + 1,
                username: isUser ? currentUserName : names[i % names.count],
                avatarIcon: isUser ? "shield.fill" : icons[Int(rng.next() % UInt64(icons.count))],
                level: isUser ? currentUserLevel : max(1, Int(20 - i) + Int(rng.next() % 5)),
                weeklyScore: isUser ? max(currentUserSaved * 0.3, score * 0.8) : score,
                streak: isUser ? currentUserStreak : max(0, Int(rng.next() % 30)),
                isCurrentUser: isUser
            ))
        }

        result.sort { $0.weeklyScore > $1.weeklyScore }
        return result.enumerated().map { index, entry in
            LeaderboardEntry(
                id: entry.id,
                rank: index + 1,
                username: entry.username,
                avatarIcon: entry.avatarIcon,
                level: entry.level,
                weeklyScore: entry.weeklyScore,
                streak: entry.streak,
                isCurrentUser: entry.isCurrentUser
            )
        }
    }

    private func formattedScore(_ score: Double) -> String {
        if score >= 1000 {
            return "$\(String(format: "%.1f", score / 1000))k"
        }
        return "$\(Int(score))"
    }
}

// MARK: - Deterministic RNG

private struct SplitMix64 {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        z = z ^ (z >> 31)
        return z
    }
}
