import SwiftUI
import SwiftData

struct CommunityView: View {
    @Query(sort: \CommunityPost.date, order: .reverse) private var posts: [CommunityPost]
    @Query private var partners: [AccountabilityPartner]
    @Query private var challenges: [ChallengeGroup]
    @Query private var profiles: [UserProfile]
    @Query private var partnerCheckIns: [PartnerCheckIn]
    @Query private var quizResults: [QuizResult]
    @Query(sort: \ChallengeInvite.createdAt, order: .reverse) private var challengeInvites: [ChallengeInvite]
    @Environment(\.modelContext) private var modelContext
    @State private var vm = CommunityViewModel()
    @State private var appeared = false
    @State private var likeTrigger = 0
    @State private var showChallengeInvite = false

    private var profile: UserProfile? { profiles.first }
    private var personality: MoneyPersonality { quizResults.first?.personality ?? .builder }
    private var partner: AccountabilityPartner? { partners.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    categoryFilter
                    shareStoryCard
                    challengeFriendButton
                    if !activeChallengeInvites.isEmpty {
                        myChallengeInvitesSection
                    }
                    feedSection
                    partnerSection
                    challengesSection
                }
                .padding(.bottom, 32)
            }
            .refreshable { }
            .background(Theme.background.ignoresSafeArea())
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
                                .background(Theme.elevated, in: .capsule)
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
            .sheet(isPresented: $showChallengeInvite) {
                ChallengeInviteView()
                    .presentationDetents([.large])
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
                withAnimation(Theme.springStagger) { appeared = true }
            }
        }
    }

    private var activeChallengeInvites: [ChallengeInvite] {
        challengeInvites.filter { $0.status == "active" || $0.status == "pending" }
    }

    // MARK: - Challenge Friend Button

    private var challengeFriendButton: some View {
        Button {
            showChallengeInvite = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.neonPurple.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "figure.2")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.neonPurple)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Challenge a Friend")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Compete head-to-head for bonus XP")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(14)
            .glassCard(accentGlow: Theme.neonPurple)
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: showChallengeInvite)
        .padding(.horizontal)
        .accessibilityLabel("Challenge a friend to compete")
    }

    // MARK: - My Challenge Invites

    private var myChallengeInvitesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(Theme.gold)
                Text("My Challenges")
                    .font(Theme.headingFont(.title3))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(activeChallengeInvites.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.goldDim, in: .capsule)
            }
            .padding(.horizontal)

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(activeChallengeInvites, id: \.id) { invite in
                        challengeInviteCard(invite)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
            .scrollIndicators(.hidden)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.08), value: appeared)
    }

    private func challengeInviteCard(_ invite: ChallengeInvite) -> some View {
        let type = FriendChallengeType.allCases.first { $0.rawValue == invite.challengeType }
        let accentColor: Color = {
            switch type {
            case .noSpend7Day: return Theme.neonRed
            case .save100: return Theme.neonEmerald
            case .complete5Quests: return Theme.neonPurple
            case .none: return Theme.accent
            }
        }()

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: type?.icon ?? "bolt.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(invite.challengeType)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 4) {
                        Image(systemName: invite.statusIcon)
                            .font(.system(size: 8))
                        Text(invite.status.capitalized)
                            .font(.caption2)
                    }
                    .foregroundStyle(accentColor)
                }
            }

            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Theme.elevated)
                            .frame(height: 5)
                        Capsule()
                            .fill(accentColor)
                            .frame(width: geo.size.width * invite.creatorProgress, height: 5)
                    }
                }
                .frame(height: 5)

                HStack {
                    Text("+\(invite.xpReward) XP")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Theme.gold)
                    Spacer()
                    Text("\(invite.daysRemaining)d left")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(14)
        .frame(width: 200)
        .glassCard(accentGlow: accentColor)
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
                                .foregroundStyle(vm.selectedCategory == category ? Theme.accent : Theme.textSecondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)

                            Rectangle()
                                .fill(vm.selectedCategory == category ? Theme.accent : .clear)
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

    // MARK: - Share Story Card

    private var shareStoryCard: some View {
        Button {
            vm.showCreatePost = true
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.accent)
                    }

                Text("Share your story...")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textMuted)

                Spacer()
            }
            .padding(14)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .light), trigger: vm.showCreatePost)
        .padding(.horizontal)
    }

    // MARK: - Feed

    private var feedSection: some View {
        LazyVStack(spacing: 12) {
            let filtered = vm.filteredPosts(posts)
            if filtered.isEmpty {
                emptyFeedState
            } else {
                ForEach(Array(filtered.enumerated()), id: \.element.id) { index, post in
                    CommunityPostCard(post: post, vm: vm, likeTrigger: $likeTrigger)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06), value: appeared)
                }
            }
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.selectedCategory)
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
                    .foregroundStyle(Theme.accent)
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
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: appeared)
    }

    private func partnerCard(_ partner: AccountabilityPartner) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.elevated)
                        .frame(width: 52, height: 52)
                        .overlay {
                            Circle()
                                .strokeBorder(Theme.accent.opacity(0.3), lineWidth: 1)
                        }
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
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
                .background(Theme.accent, in: .rect(cornerRadius: 12))
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
                        .strokeBorder(Theme.accent.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .foregroundStyle(Theme.accent.opacity(0.6))
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
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.accent.opacity(0.12), in: .rect(cornerRadius: 12))
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
                    .foregroundStyle(Theme.accent)
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
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.15), value: appeared)
    }


}

// MARK: - Post Card

struct CommunityPostCard: View {
    let post: CommunityPost
    let vm: CommunityViewModel
    @Binding var likeTrigger: Int



    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Theme.elevated)
                    .frame(width: 38, height: 38)
                    .overlay {
                        Circle()
                            .strokeBorder(Theme.accent.opacity(0.25), lineWidth: 1)
                    }
                    .overlay {
                        Text(String(post.authorName.prefix(1)))
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Theme.accent)
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

                Text(post.mood)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.elevated, in: .capsule)
            }

            Text(post.content)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.85))
                .lineSpacing(4)

            HStack(spacing: 4) {
                Text(post.category)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.elevated, in: .capsule)

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        vm.toggleLike(on: post)
                        likeTrigger += 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLikedByUser ? "heart.fill" : "heart")
                            .foregroundStyle(post.isLikedByUser ? Theme.accent : Theme.textSecondary)
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
                            .fill(Theme.accent.opacity(0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: challenge.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text(challenge.hashtag)
                            .font(.caption)
                            .foregroundStyle(Theme.accent.opacity(0.8))
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
                                .fill(Theme.elevated)
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
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.accent.opacity(0.1), in: .rect(cornerRadius: 8))
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
