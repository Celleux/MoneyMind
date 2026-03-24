import SwiftUI
import SwiftData

struct CreatePostSheet: View {
    let authorName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \CommunityPost.date, order: .reverse) private var allPosts: [CommunityPost]
    @State private var content: String = ""
    @State private var selectedCategory: String = "Victories"
    @State private var selectedMood: String = "Hopeful"
    @State private var showToxicWarning = false
    @State private var showCrisisOverlay = false
    @State private var postTrigger = 0

    private let categories = ["Victories", "Struggles", "Tips", "Questions"]
    private var profile: UserProfile? { profiles.first }
    private let charLimit = 500

    private var postsToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return allPosts.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    categoryPicker
                    moodPicker
                    textSection
                    postButton
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("This may not be supportive", isPresented: $showToxicWarning) {
                Button("Rephrase") { }
                Button("Post Anyway", role: .destructive) { submitPost() }
            } message: {
                Text("Your message contains language that might not be supportive to others. Would you like to rephrase?")
            }
            .fullScreenCover(isPresented: $showCrisisOverlay) {
                EmergencyCrisisView()
            }
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Category")
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { cat in
                    Button {
                        withAnimation(.snappy) { selectedCategory = cat }
                    } label: {
                        Text(cat)
                            .font(Typography.labelSmall)
                            .foregroundStyle(selectedCategory == cat ? Theme.background : Theme.textSecondary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == cat ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.cardSurface),
                                in: .capsule
                            )
                    }
                    .sensoryFeedback(.selection, trigger: selectedCategory)
                    .accessibilityLabel("Category: \(cat)")
                }
            }
        }
    }

    private var moodPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How are you feeling?")
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                ForEach(CommunityContent.postMoods, id: \.name) { mood in
                    Button {
                        withAnimation(.snappy) { selectedMood = mood.name }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: mood.icon)
                                .font(Typography.labelSmall)
                            Text(mood.name)
                                .font(Typography.labelSmall)
                        }
                        .foregroundStyle(selectedMood == mood.name ? Theme.background : moodColor(mood.color))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedMood == mood.name
                                ? AnyShapeStyle(moodColor(mood.color))
                                : AnyShapeStyle(moodColor(mood.color).opacity(0.12)),
                            in: .capsule
                        )
                    }
                    .sensoryFeedback(.selection, trigger: selectedMood)
                    .accessibilityLabel("Mood: \(mood.name)")
                }
            }
        }
    }

    private var textSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share with the community")
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.textPrimary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $content)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .background(Theme.cardSurface, in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Theme.textSecondary.opacity(0.15), lineWidth: 1)
                    )

                if content.isEmpty {
                    Text("What's on your mind? Share a win, ask a question, or just say hi...")
                        .font(Typography.bodyLarge)
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }

            HStack {
                Text("\(content.count)/\(charLimit)")
                    .font(Typography.labelSmall)
                    .foregroundStyle(content.count > charLimit ? Theme.emergency : Theme.textSecondary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "eye.slash.fill")
                        .font(Typography.labelSmall)
                    Text("Posting as \(authorName)")
                        .font(Typography.labelSmall)
                }
                .foregroundStyle(Theme.textSecondary.opacity(0.7))
            }
        }
    }

    private var postButton: some View {
        Button {
            let result = CommunityContent.containsCrisisContent(content) ? ModerationResult.crisis :
                         CommunityContent.containsToxicContent(content) ? ModerationResult.toxic : .safe

            switch result {
            case .crisis:
                showCrisisOverlay = true
            case .toxic:
                showToxicWarning = true
            case .safe:
                submitPost()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                Text("Post Anonymously")
                    .font(Typography.headingMedium)
            }
            .foregroundStyle(Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                content.isEmpty || content.count > charLimit
                    ? AnyShapeStyle(Theme.textSecondary.opacity(0.3))
                    : AnyShapeStyle(Theme.accentGradient),
                in: .rect(cornerRadius: 12)
            )
        }
        .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
        .disabled(content.isEmpty || content.count > charLimit)
        .sensoryFeedback(.success, trigger: postTrigger)
        .accessibilityLabel("Post anonymously")
    }

    private func submitPost() {
        let post = CommunityPost(
            authorName: authorName,
            content: content,
            category: selectedCategory,
            mood: selectedMood
        )
        modelContext.insert(post)

        if let profile {
            let today = Calendar.current.startOfDay(for: Date())
            if !Calendar.current.isDate(profile.lastPostCountReset, inSameDayAs: today) {
                profile.communityPostsToday = 0
                profile.lastPostCountReset = Date()
            }
            if profile.communityPostsToday < 3 {
                profile.xpPoints += XPAction.communityPost.xpValue
                profile.communityPostsToday += 1
            }
        }

        postTrigger += 1
        dismiss()
    }

    private func moodColor(_ colorName: String) -> Color {
        switch colorName {
        case "green": return Theme.accentGreen
        case "red": return Theme.emergency
        case "teal": return Theme.teal
        case "amber": return Theme.gold
        case "gold": return Theme.gold
        case "purple": return Color.purple
        default: return Theme.textSecondary
        }
    }
}
