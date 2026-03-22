import SwiftUI
import SwiftData

nonisolated enum AppTab: Int, Sendable {
    case home, wallet, tools, community, profile
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showSOSSheet = false
    @State private var sosPulse = false
    @State private var showSiriUrgeSurf = false
    @State private var showSiriCheckIn = false
    @State private var showQuickTransaction = false
    @State private var fabBounce: Bool = false
    @State private var vibeCheckTransaction: Transaction?
    @State private var showVibeCheck: Bool = false
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var recentTransactions: [Transaction]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                Tab("Home", systemImage: "house.fill", value: .home) {
                    HomeView()
                }
                Tab("Wallet", systemImage: "wallet.bifold.fill", value: .wallet) {
                    WalletView()
                }
                Tab("Tools", systemImage: "wrench.and.screwdriver.fill", value: .tools) {
                    ToolkitView()
                }
                Tab("Community", systemImage: "person.3.fill", value: .community) {
                    CommunityView()
                }
                Tab("Profile", systemImage: "person.crop.circle.fill", value: .profile) {
                    ProfileView()
                }
            }
            .tint(Theme.accent)

            VStack(spacing: 12) {
                fabButton
                sosButton
            }
        }
        .sheet(isPresented: $showQuickTransaction) {
            QuickTransactionSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(Theme.background)
        }
        .sheet(isPresented: $showSOSSheet) {
            SOSEmergencySheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showSiriUrgeSurf) {
            UrgeSurfView(siriTriggered: true)
        }
        .fullScreenCover(isPresented: $showSiriCheckIn) {
            SiriCheckInView()
        }
        .syncWidgetData()
        .onReceive(NotificationCenter.default.publisher(for: .siriUrgeDetected)) { _ in
            showSiriUrgeSurf = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .siriCheckInRequested)) { _ in
            showSiriCheckIn = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .transactionSaved)) { notification in
            if let tx = notification.object as? Transaction {
                vibeCheckTransaction = tx
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showVibeCheck = true
                }
            }
        }
        .overlay {
            if showVibeCheck, let tx = vibeCheckTransaction {
                VibeCheckOverlay(
                    transaction: tx,
                    onSelect: { vibe in
                        tx.moodEmoji = vibe.emoji
                        let entry = VibeCheckEntry(
                            transactionID: "\(tx.persistentModelID.hashValue)",
                            emoji: vibe.emoji,
                            sentiment: vibe.sentiment,
                            amount: tx.amount,
                            categoryName: tx.category
                        )
                        modelContext.insert(entry)
                        showVibeCheck = false
                        vibeCheckTransaction = nil
                    },
                    onSkip: {
                        showVibeCheck = false
                        vibeCheckTransaction = nil
                    }
                )
                .transition(.identity)
            }
        }
    }

    private var fabButton: some View {
        Button {
            fabBounce.toggle()
            showQuickTransaction = true
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 56, height: 56)
                    .shadow(color: Theme.accent.opacity(0.2), radius: 24, y: 8)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: fabBounce)
        .accessibilityLabel("Add transaction")
    }

    private var sosButton: some View {
        Button {
            showSOSSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.emergency.opacity(0.25))
                    .frame(width: 56, height: 56)
                    .scaleEffect(sosPulse ? 1.3 : 1.0)
                    .opacity(sosPulse ? 0 : 0.6)

                Circle()
                    .fill(Theme.emergency)
                    .frame(width: 44, height: 44)
                    .shadow(color: Theme.emergency.opacity(0.4), radius: 8, y: 2)

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(45))
            }
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Emergency help")
        .accessibilityHint("Opens emergency support tools")
        .padding(.trailing, 16)
        .padding(.bottom, 4)
        .sensoryFeedback(.impact(weight: .heavy), trigger: showSOSSheet)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                sosPulse = true
            }
        }
    }
}
