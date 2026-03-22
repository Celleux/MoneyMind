import Foundation
import SwiftData

@Model
class CommunityPost {
    var id: UUID
    var authorName: String
    var content: String
    var category: String
    var mood: String
    var likes: Int
    var replyCount: Int
    var date: Date
    var isLikedByUser: Bool

    init(authorName: String, content: String, category: String, mood: String, likes: Int = 0, replyCount: Int = 0) {
        self.id = UUID()
        self.authorName = authorName
        self.content = content
        self.category = category
        self.mood = mood
        self.likes = likes
        self.replyCount = replyCount
        self.date = Date()
        self.isLikedByUser = false
    }
}
