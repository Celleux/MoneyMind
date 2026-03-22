import SwiftUI

nonisolated enum AppTab: Int, Sendable {
    case home, wallet, tools, community, profile
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showSOSSheet = false
    @State private var sosPulse = false
    @State private var showSiriUrgeSurf = false
    @State private var showSiriCheckIn = false

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

            sosButton
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
        .onReceive(NotificationCenter.default.publisher(for: .siriUrgeDetected)) { _ in
            showSiriUrgeSurf = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .siriCheckInRequested)) { _ in
            showSiriCheckIn = true
        }
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
        .padding(.bottom, 60)
        .sensoryFeedback(.impact(weight: .heavy), trigger: showSOSSheet)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: false)) {
                sosPulse = true
            }
        }
    }
}
