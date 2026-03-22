import Foundation

enum CommunityContent {
    static let adjectives = [
        "Brave", "Calm", "Steady", "Wise", "Bold", "Gentle", "Swift", "Kind",
        "Bright", "Noble", "Keen", "True", "Free", "Strong", "Clear", "Warm",
        "Quick", "Still", "Deep", "Fair", "Pure", "Safe", "Sure", "Wild"
    ]

    static let animals = [
        "Fox", "Owl", "Eagle", "Raven", "Bear", "Wolf", "Hawk", "Deer",
        "Otter", "Falcon", "Lynx", "Crane", "Heron", "Robin", "Seal", "Dove",
        "Tiger", "Lion", "Panda", "Whale", "Swan", "Finch", "Wren", "Jay"
    ]

    static func generateAnonymousName() -> String {
        let adj = adjectives.randomElement() ?? "Brave"
        let animal = animals.randomElement() ?? "Fox"
        return "\(adj)\(animal)"
    }

    static let crisisKeywords = [
        "suicide", "kill myself", "end it all", "no reason to live",
        "self-harm", "want to die", "can't go on", "what's the point",
        "nobody cares", "better off without me", "hurt myself",
        "end my life", "not worth living", "give up on life"
    ]

    static let toxicKeywords = [
        "idiot", "stupid", "loser", "pathetic", "worthless", "disgusting",
        "shut up", "hate you", "kill you", "moron", "dumb", "trash",
        "useless", "failure", "weak"
    ]

    nonisolated(unsafe) static let postCategories = ["All", "Victories", "Struggles", "Tips", "Questions"]

    nonisolated(unsafe) static let postMoods: [(name: String, icon: String, color: String)] = [
        ("Hopeful", "circle.fill", "green"),
        ("Struggling", "triangle.fill", "red"),
        ("Grateful", "diamond.fill", "teal"),
        ("Anxious", "square.fill", "amber"),
        ("Proud", "star.fill", "gold"),
        ("Seeking Help", "heart.fill", "purple")
    ]

    static func containsCrisisContent(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return crisisKeywords.contains { lowered.contains($0) }
    }

    static func containsToxicContent(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return toxicKeywords.contains { lowered.localizedStandardContains($0) }
    }

    nonisolated(unsafe) static let samplePosts: [(author: String, content: String, category: String, mood: String, likes: Int, replies: Int, hoursAgo: Double)] = [
        ("BraveFox", "Day 14! Resisted a $200 impulse purchase today. The urge was strong but I used the breathing exercise and it passed. Feeling proud!", "Victories", "Proud", 24, 3, 2),
        ("CalmOwl", "Tip: I put a 48-hour rule on all purchases over $50. If I still want it after 48 hours, I reconsider. 90% of the time, the urge passes.", "Tips", "Hopeful", 56, 8, 5),
        ("SteadyEagle", "Hit my first $500 saved milestone! Started this journey 3 weeks ago feeling hopeless. Now I'm seeing real progress.", "Victories", "Grateful", 89, 12, 12),
        ("WiseRaven", "Struggling today. Almost gave in to online shopping. Came here instead. Sometimes just reading your stories helps.", "Struggles", "Struggling", 34, 15, 8),
        ("GentleDeer", "Question: How do you handle social pressure to spend? My friends always want to go out to expensive dinners.", "Questions", "Anxious", 18, 22, 3),
        ("BoldHawk", "3 months gambling-free today. Never thought I'd make it this far. If you're on day 1, keep going. It gets easier.", "Victories", "Proud", 142, 31, 1),
        ("KindOtter", "I finally told my partner about my spending problem. They were so understanding. Don't carry the weight alone.", "Tips", "Grateful", 67, 9, 18),
        ("SwiftFalcon", "Does anyone else get triggered by ads? I've started using ad blockers and it's helped a lot with impulse control.", "Questions", "Seeking Help", 29, 14, 6),
        ("DeepWhale", "Relapsed yesterday. Feeling disappointed but I did the spending autopsy and it helped me understand what happened.", "Struggles", "Struggling", 45, 19, 14),
        ("ClearCrane", "Tip: Replace the dopamine hit of buying with something free — I go for walks, call a friend, or do 10 min of yoga.", "Tips", "Hopeful", 73, 5, 24)
    ]

    nonisolated(unsafe) static let sampleChallenges: [(name: String, hashtag: String, description: String, participants: Int, savings: Double, goal: Double, icon: String, daysLeft: Int)] = [
        ("No Buy March", "#NoBuyMarch", "Only essentials for the entire month. Track everything you resist!", 1247, 342_500, 500_000, "cart.badge.minus", 10),
        ("30-Day Reset", "#30DayReset", "Reset your spending habits in 30 days. One mindful choice at a time.", 892, 156_200, 250_000, "arrow.counterclockwise", 18),
        ("Gamble Free April", "#GambleFreeApril", "Support each other through a gambling-free month. You're not alone.", 634, 89_400, 150_000, "shield.checkered", 41),
        ("$1K Challenge", "#Save1K", "Save $1,000 collectively as a community this quarter.", 2103, 847_300, 1_000_000, "dollarsign.circle", 52)
    ]

    nonisolated(unsafe) static let guidelines: [(icon: String, title: String, description: String)] = [
        ("heart.fill", "Be Supportive", "Lift each other up. Every person here is working toward a better relationship with money."),
        ("eye.slash.fill", "Stay Anonymous", "Never share personal identifying information. Your privacy and safety come first."),
        ("exclamationmark.triangle.fill", "No Financial Advice", "Share experiences, not investment tips. We're peers, not advisors."),
        ("phone.fill", "Report Crisis Content", "If you see someone in danger, use the SOS button. We take safety seriously."),
        ("hand.raised.fill", "Zero Tolerance", "Harassment, bullying, and harmful content will be removed immediately."),
        ("sparkles", "Celebrate, Don't Compare", "Everyone's journey is different. Celebrate progress without comparison.")
    ]
}
