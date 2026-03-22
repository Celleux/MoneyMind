import SwiftUI
import SwiftData

@Observable
class CommunityViewModel {
    var selectedCategory: String = "All"
    var showCreatePost = false
    var showGuidelines = false
    var showFindPartner = false
    var showPartnerCheckIn = false
    var showChallengeDetail = false
    var selectedChallenge: ChallengeGroup?
    var showCrisisOverlay = false
    var showToxicityWarning = false

    func filteredPosts(_ posts: [CommunityPost]) -> [CommunityPost] {
        if selectedCategory == "All" { return posts }
        return posts.filter { $0.category == selectedCategory }
    }

    func postsToday(_ posts: [CommunityPost]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return posts.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }.count
    }

    func canPostToday(_ posts: [CommunityPost]) -> Bool {
        postsToday(posts) < 3
    }

    func toggleLike(on post: CommunityPost) {
        if post.isLikedByUser {
            post.likes -= 1
        } else {
            post.likes += 1
        }
        post.isLikedByUser.toggle()
    }

    func moderateContent(_ text: String) -> ModerationResult {
        if CommunityContent.containsCrisisContent(text) {
            return .crisis
        }
        if CommunityContent.containsToxicContent(text) {
            return .toxic
        }
        return .safe
    }

    func seedSamplePosts(context: ModelContext, existingPosts: [CommunityPost]) {
        guard existingPosts.isEmpty else { return }
        for sample in CommunityContent.samplePosts {
            let post = CommunityPost(
                authorName: sample.author,
                content: sample.content,
                category: sample.category,
                mood: sample.mood,
                likes: sample.likes,
                replyCount: sample.replies
            )
            post.date = Date().addingTimeInterval(-sample.hoursAgo * 3600)
            context.insert(post)
        }
    }

    func seedSampleChallenges(context: ModelContext, existingChallenges: [ChallengeGroup]) {
        guard existingChallenges.isEmpty else { return }
        for sample in CommunityContent.sampleChallenges {
            let challenge = ChallengeGroup(
                name: sample.name,
                hashtag: sample.hashtag,
                groupDescription: sample.description,
                startDate: Date().addingTimeInterval(-Double(30 - sample.daysLeft) * 86400),
                endDate: Date().addingTimeInterval(Double(sample.daysLeft) * 86400),
                participantCount: sample.participants,
                collectiveSavings: sample.savings,
                savingsGoal: sample.goal,
                iconName: sample.icon
            )
            context.insert(challenge)
        }
    }

    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        if hours < 24 { return "\(hours)h ago" }
        if days == 1 { return "1d ago" }
        return "\(days)d ago"
    }
}

nonisolated enum ModerationResult: Sendable {
    case safe
    case crisis
    case toxic
}
