import SwiftUI

// TODO: Replace with real friend data from backend

nonisolated struct FriendActivity: Identifiable, Sendable {
    let id: String
    let username: String
    let avatarIcon: String
    let avatarColor: Color
    let activityText: String
    let timeAgo: String

    nonisolated static let mockData: [FriendActivity] = [
        FriendActivity(id: "1", username: "Sarah", avatarIcon: "person.fill", avatarColor: Color(hex: 0x8B5CF6), activityText: "saved $45 today", timeAgo: "2h ago"),
        FriendActivity(id: "2", username: "Mike", avatarIcon: "flame.fill", avatarColor: Color(hex: 0xF59E0B), activityText: "is on a 12-day streak", timeAgo: "3h ago"),
        FriendActivity(id: "3", username: "Emma", avatarIcon: "arrow.up.circle.fill", avatarColor: Theme.accent, activityText: "just hit Level 8", timeAgo: "5h ago"),
        FriendActivity(id: "4", username: "James", avatarIcon: "checkmark.seal.fill", avatarColor: Color(hex: 0x3B82F6), activityText: "completed 'No Coffee Week'", timeAgo: "6h ago"),
        FriendActivity(id: "5", username: "Olivia", avatarIcon: "star.fill", avatarColor: Color(hex: 0xEC4899), activityText: "unlocked a rare card", timeAgo: "8h ago"),
        FriendActivity(id: "6", username: "Noah", avatarIcon: "trophy.fill", avatarColor: Color(hex: 0xF5C542), activityText: "ranked #3 on the leaderboard", timeAgo: "9h ago"),
        FriendActivity(id: "7", username: "Ava", avatarIcon: "shield.fill", avatarColor: Color(hex: 0x06B6D4), activityText: "resisted a $120 impulse buy", timeAgo: "10h ago"),
        FriendActivity(id: "8", username: "Liam", avatarIcon: "bolt.fill", avatarColor: Color(hex: 0xA855F7), activityText: "earned 2x XP on a quest", timeAgo: "11h ago"),
        FriendActivity(id: "9", username: "Sophia", avatarIcon: "heart.fill", avatarColor: Color(hex: 0xEF4444), activityText: "saved $200 this week", timeAgo: "12h ago"),
        FriendActivity(id: "10", username: "Ethan", avatarIcon: "chart.line.uptrend.xyaxis", avatarColor: Theme.accent, activityText: "hit a 30-day savings milestone", timeAgo: "1d ago"),
    ]
}

struct FriendActivityView: View {
    @Environment(\.dismiss) private var dismiss

    private let activities = FriendActivity.mockData

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(activities) { activity in
                        friendActivityRow(activity)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
            .scrollIndicators(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Friend Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }

    private func friendActivityRow(_ activity: FriendActivity) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(activity.avatarColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: activity.avatarIcon)
                    .font(Typography.headingMedium)
                    .foregroundStyle(activity.avatarColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 0) {
                    Text(activity.username)
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.textPrimary)
                    Text(" \(activity.activityText)")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textSecondary)
                }
                .lineLimit(1)

                Text(activity.timeAgo)
                    .font(Typography.bodySmall)
                    .foregroundStyle(Theme.textMuted)
            }

            Spacer()
        }
        .padding(14)
        .splurjCard(.subtle)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.username) \(activity.activityText), \(activity.timeAgo)")
    }
}
