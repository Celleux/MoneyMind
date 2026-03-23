import SwiftUI
import SwiftData

struct ChallengeInviteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @Query(sort: \ChallengeInvite.createdAt, order: .reverse) private var invites: [ChallengeInvite]
    @State private var selectedType: FriendChallengeType?
    @State private var showShareSheet = false
    @State private var shareMessage = ""
    @State private var appeared = false
    @State private var createTrigger = 0

    private var creatorName: String { profiles.first?.name ?? "A Splurj user" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    challengeTypesSection
                    if !activeInvites.isEmpty {
                        myChallengesSection
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Challenge a Friend")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [shareMessage])
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "figure.2")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Theme.accent)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.6)

            Text("Pick a Challenge")
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)

            Text("Challenge a friend and compete head-to-head.\nThe winner earns bonus XP and a Victor badge!")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: appeared)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // MARK: - Challenge Types

    private var challengeTypesSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(FriendChallengeType.allCases.enumerated()), id: \.element) { index, type in
                challengeTypeCard(type, index: index)
            }
        }
        .padding(.horizontal)
    }

    private func challengeTypeCard(_ type: FriendChallengeType, index: Int) -> some View {
        let isSelected = selectedType == type
        let accentColor = colorForType(type)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedType = type
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: type.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(accentColor)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.rawValue)
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        Text(type.description)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("+\(type.xpReward)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Theme.gold)
                        Text("XP")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(Theme.textMuted)
                    }
                }
                .padding(16)

                if isSelected {
                    Divider()
                        .background(Theme.divider)

                    Button {
                        createAndShareChallenge(type)
                        createTrigger += 1
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Send Challenge")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(accentColor, in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .glassCard(accentGlow: isSelected ? accentColor : nil)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .strokeBorder(accentColor.opacity(0.4), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedType)
        .sensoryFeedback(.impact(weight: .medium), trigger: createTrigger)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.08), value: appeared)
        .accessibilityLabel("\(type.rawValue) challenge, \(type.xpReward) XP reward")
    }

    // MARK: - My Challenges

    private var activeInvites: [ChallengeInvite] {
        invites.filter { $0.status == "active" || $0.status == "pending" }
    }

    private var myChallengesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Theme.gold)
                Text("My Challenges")
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Text("\(activeInvites.count) active")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal)

            ForEach(activeInvites, id: \.id) { invite in
                myChallengeRow(invite)
            }
        }
    }

    private func myChallengeRow(_ invite: ChallengeInvite) -> some View {
        let type = FriendChallengeType.allCases.first { $0.rawValue == invite.challengeType }
        let accentColor = type.map { colorForType($0) } ?? Theme.accent

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: type?.icon ?? "bolt.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(invite.challengeType)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 8) {
                    Label(invite.status.capitalized, systemImage: invite.statusIcon)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(accentColor)

                    if invite.daysRemaining > 0 {
                        Text("\(invite.daysRemaining)d left")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(invite.creatorProgress * 100))%")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text("progress")
                    .font(.caption2)
                    .foregroundStyle(Theme.textMuted)
            }
        }
        .padding(14)
        .glassCard()
        .padding(.horizontal)
    }

    // MARK: - Actions

    private func createAndShareChallenge(_ type: FriendChallengeType) {
        let invite = ChallengeInvite(
            challengeType: type.rawValue,
            creatorName: creatorName,
            status: "pending",
            expiresAt: Date().addingTimeInterval(type.duration),
            xpReward: type.xpReward
        )
        modelContext.insert(invite)
        try? modelContext.save()

        // TODO: Implement Universal Links with server backend
        shareMessage = "I challenge you to \(type.rawValue)! Join me on Splurj: splurj.app/challenge/\(invite.id)?utm_source=challenge&utm_medium=share&utm_campaign=friend_challenge"
        showShareSheet = true
    }

    private func colorForType(_ type: FriendChallengeType) -> Color {
        switch type {
        case .noSpend7Day: return Theme.neonRed
        case .save100: return Theme.neonEmerald
        case .complete5Quests: return Theme.neonPurple
        }
    }
}

