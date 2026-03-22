import SwiftUI
import SwiftData

struct CommunityView: View {
    @Query(sort: \CommunityPost.date, order: .reverse) private var posts: [CommunityPost]
    @Query private var partners: [AccountabilityPartner]
    @Query private var challenges: [ChallengeGroup]
    @Query private var profiles: [UserProfile]
    @Query private var partnerCheckIns: [PartnerCheckIn]
    @Query private var quizResults: [QuizResult]
    @Environment(\.modelContext) private var modelContext
    @State private var vm = CommunityViewModel()
    @State private var appeared = false
    @State private var likeTrigger = 0

    private var profile: UserProfile? { profiles.first }
    private var personality: MoneyPersonality { quizResults.first?.personality ?? .builder }
    private var partner: AccountabilityPartner? { partners.first }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        categoryFilter
                        feedSection
                        partnerSection
                        challengesSection
                    }
                    .padding(.bottom, 100)
                }
                .refreshable { }
                .background(Theme.background.ignoresSafeArea())

                createPostButton
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        if vm.canPostToday(posts) {
                            Text("\(3 - vm.postsToday(posts)) left")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.cardSurface, in: .capsule)
                        }
                    }
                }
            }
            .sheet(isPresented: $vm.showCreatePost) {
                CreatePostSheet(authorName: profile?.anonymousName ?? "Anonymous")
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
            }
            .sheet(isPresented: $vm.showFindPartner) {
                FindPartnerSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $vm.showPartnerCheckIn) {
                PartnerCheckInSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $vm.selectedChallenge) { challenge in
                ChallengeDetailSheet(challenge: challenge)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .overlay {
                if let profile, !profile.hasSeenCommunityGuidelines {
                    CommunityGuidelinesOverlay {
                        profile.hasSeenCommunityGuidelines = true
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .onAppear {
                vm.seedSamplePosts(context: modelContext, existingPosts: posts)
                vm.seedSampleChallenges(context: modelContext, existingChallenges: challenges)
                withAnimation(.spring(response: 0.5)) { appeared = true }
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(CommunityContent.postCategories, id: \.self) { category in
                    Button {
                        withAnimation(.snappy) { vm.selectedCategory = category }
                    } label: {
                        VStack(spacing: 6) {
                            Text(category)
                                .font(.subheadline.weight(vm.selectedCategory == category ? .semibold : .regular))
                                .foregroundStyle(vm.selectedCategory == category ? Theme.accentGreen : Theme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)

                            Rectangle()
                                .fill(vm.selectedCategory == category ? Theme.accentGreen : .clear)
                                .frame(height: 2)
                                .clipShape(.rect(cornerRadius: 1))
                        }
                    }
                    .sensoryFeedback(.selection, trigger: vm.selectedCategory)
                    .accessibilityLabel("Filter: \(category)")
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    // MARK: - Feed

    private var feedSection: some View {
        LazyVStack(spacing: 12) {
            let filtered = vm.filteredPosts(posts)
            if filtered.isEmpty {
                emptyFeedState
            } else {
                ForEach(filtered) { post in
                    CommunityPostCard(post: post, vm: vm, likeTrigger: $likeTrigger)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding(.horizontal)
        .animation(.snappy, value: vm.selectedCategory)
    }

    private var emptyFeedState: some View {
        PersonalityEmptyStateView(
            personality: personality,
            icon: "bubble.left.and.text.bubble.right.fill",
            secondaryIcon: "person.2.fill",
            headline: "Be the First to Share",
            subtext: "Start a conversation and connect\nwith the Splurj community",
            buttonLabel: "Create a Post",
            buttonIcon: "square.and.pencil"
        ) {
            vm.showCreatePost = true
        }
        .frame(height: 420)
    }

    // MARK: - Partner Section

    private var partnerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(Theme.teal)
                Text("Accountability Partner")
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal)

            if let partner {
                partnerCard(partner)
            } else {
                findPartnerPrompt
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.1), value: appeared)
    }

    private func partnerCard(_ partner: AccountabilityPartner) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.teal.opacity(0.3), Theme.cardSurface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.teal)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(partner.partnerName)
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 8) {
                        Label("\(partner.streakLength)d streak", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(Theme.gold)
                        if let lastDate = partner.lastCheckInDate {
                            Text("· Last check-in \(lastDate, format: .relative(presentation: .named))")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }

                Spacer()
            }

            Button {
                vm.showPartnerCheckIn = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.message.fill")
                    Text("Weekly Check-In")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.teal, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: vm.showPartnerCheckIn)
            .accessibilityLabel("Send weekly check-in to partner")
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal)
    }

    private var findPartnerPrompt: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .strokeBorder(Theme.teal.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Theme.teal.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Find an Accountability Partner")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Knowing someone is watching helps maintain commitment")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            Button {
                vm.showFindPartner = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Find a Partner")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Theme.teal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.teal.opacity(0.12), in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .light), trigger: vm.showFindPartner)
            .accessibilityLabel("Find an accountability partner")
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal)
    }

    // MARK: - Challenges Section

    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(Theme.accentGreen)
                Text("Active Challenges")
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal)

            ScrollView(.horizontal) {
                HStack(spacing: 14) {
                    ForEach(challenges) { challenge in
                        ChallengeCard(challenge: challenge) {
                            vm.selectedChallenge = challenge
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.5).delay(0.15), value: appeared)
    }

    // MARK: - Create Post Button

    private var createPostButton: some View {
        Button {
            vm.showCreatePost = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.background)
                .frame(width: 56, height: 56)
                .background(Theme.accentGradient, in: Circle())
                .shadow(color: Theme.accentGreen.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Create new post")
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Post Card

struct CommunityPostCard: View {
    let post: CommunityPost
    let vm: CommunityViewModel
    @Binding var likeTrigger: Int

    private var moodInfo: (icon: String, color: Color) {
        switch post.mood {
        case "Hopeful": return ("circle.fill", Theme.accentGreen)
        case "Struggling": return ("triangle.fill", Theme.emergency)
        case "Grateful": return ("diamond.fill", Theme.teal)
        case "Anxious": return ("square.fill", Theme.gold)
        case "Proud": return ("star.fill", Theme.gold)
        case "Seeking Help": return ("heart.fill", Color.purple)
        default: return ("circle.fill", Theme.textSecondary)
        }
    }

    private var categoryColor: Color {
        switch post.category {
        case "Victories": return Theme.accentGreen
        case "Struggles": return Theme.emergency.opacity(0.8)
        case "Tips": return Theme.gold
        case "Questions": return Theme.teal
        default: return Theme.textSecondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [moodInfo.color.opacity(0.25), Theme.cardSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)
                    .overlay {
                        Text(String(post.authorName.prefix(1)))
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(moodInfo.color)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(vm.timeAgo(from: post.date))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: moodInfo.icon)
                        .font(.system(size: 8))
                        .foregroundStyle(moodInfo.color)
                    Text(post.mood)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(moodInfo.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(moodInfo.color.opacity(0.12), in: .capsule)
            }

            Text(post.content)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.85))
                .lineSpacing(4)

            HStack(spacing: 4) {
                Text(post.category)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(categoryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(categoryColor.opacity(0.12), in: .capsule)

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        vm.toggleLike(on: post)
                        likeTrigger += 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLikedByUser ? "heart.fill" : "heart")
                            .foregroundStyle(post.isLikedByUser ? Theme.emergency : Theme.textSecondary)
                            .contentTransition(.symbolEffect(.replace))
                        Text("\(post.likes)")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .font(.caption)
                }
                .sensoryFeedback(.impact(weight: .light), trigger: likeTrigger)
                .accessibilityLabel(post.isLikedByUser ? "Unlike" : "Like")

                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(post.replyCount)")
                }
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
                .padding(.leading, 8)
            }
        }
        .padding(16)
        .glassCard()
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let challenge: ChallengeGroup
    let onTap: () -> Void
    @State private var joinTrigger = 0

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Theme.accentGreen.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: challenge.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.accentGreen)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(challenge.hashtag)
                            .font(.caption)
                            .foregroundStyle(Theme.accentGreen.opacity(0.8))
                    }
                }

                Text(challenge.groupDescription)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)

                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Theme.cardSurface)
                                .frame(height: 6)
                            Capsule()
                                .fill(Theme.accentGradient)
                                .frame(width: geo.size.width * challenge.progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Label("\(challenge.participantCount)", systemImage: "person.2.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text("\(challenge.daysRemaining)d left")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Theme.gold)
                    }
                }

                if challenge.isJoined {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Joined")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.accentGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.accentGreen.opacity(0.1), in: .rect(cornerRadius: 8))
                } else {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            challenge.isJoined = true
                            challenge.participantCount += 1
                            joinTrigger += 1
                        }
                    } label: {
                        Text("Join Challenge")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Theme.accentGradient, in: .rect(cornerRadius: 8))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.impact(weight: .medium), trigger: joinTrigger)
                    .accessibilityLabel("Join \(challenge.name) challenge")
                }
            }
            .padding(16)
            .frame(width: 260)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}
