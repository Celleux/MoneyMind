import SwiftUI

enum ToolType: String, CaseIterable, Identifiable {
    case urgeSurf
    case haltCheck
    case coolingOff
    case imaginal
    case emergency
    case intentions
    case coach

    var id: String { rawValue }

    var title: String {
        switch self {
        case .urgeSurf: "Urge Surf"
        case .haltCheck: "HALT Check"
        case .coolingOff: "Cooling Off"
        case .imaginal: "Desensitization"
        case .emergency: "Emergency"
        case .intentions: "If-Then Plans"
        case .coach: "AI Coach"
        }
    }

    var subtitle: String {
        switch self {
        case .urgeSurf: "Ride the wave with guided breathing"
        case .haltCheck: "Check what's really driving the urge"
        case .coolingOff: "Wait it out with a countdown timer"
        case .imaginal: "Guided visualization exercise"
        case .emergency: "Crisis support & grounding"
        case .intentions: "Build your coping plans"
        case .coach: "Your personal wellness coach"
        }
    }

    var icon: String {
        switch self {
        case .urgeSurf: "water.waves"
        case .haltCheck: "hand.raised.fill"
        case .coolingOff: "timer"
        case .imaginal: "brain.fill"
        case .emergency: "cross.fill"
        case .intentions: "lightbulb.fill"
        case .coach: "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .urgeSurf: Theme.teal
        case .haltCheck: Color(red: 1.0, green: 0.6, blue: 0.2)
        case .coolingOff: Color(red: 0.3, green: 0.5, blue: 1.0)
        case .imaginal: Color(red: 0.6, green: 0.3, blue: 0.9)
        case .emergency: Theme.emergency
        case .intentions: Theme.accentGreen
        case .coach: Theme.teal
        }
    }
}

struct ToolkitView: View {
    @State private var selectedTool: ToolType?
    @State private var emergencyPulse = false
    @State private var showCoach = false
    @State private var showDNSBlocking = false
    @State private var showOneSecGuide = false
    @AppStorage("blockingEnabled") private var blockingEnabled = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    urgentHelpBanner

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(ToolType.allCases.filter { $0 != .coach }) { tool in
                            ToolCard(tool: tool, emergencyPulse: emergencyPulse) {
                                selectedTool = tool
                            }
                        }
                    }

                    coachCard

                    blockingSection
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(item: $selectedTool) { tool in
                toolDestination(tool)
            }
            .fullScreenCover(isPresented: $showCoach) {
                CoachChatView()
            }
            .fullScreenCover(isPresented: $showDNSBlocking) {
                DNSBlockingWizardView()
            }
            .fullScreenCover(isPresented: $showOneSecGuide) {
                OneSecBreathingGuideView()
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    emergencyPulse = true
                }
            }
        }
    }

    @ViewBuilder
    private func toolDestination(_ tool: ToolType) -> some View {
        switch tool {
        case .urgeSurf:
            UrgeSurfView()
        case .haltCheck:
            HALTCheckView()
        case .coolingOff:
            CoolingOffView()
        case .imaginal:
            ImaginalDesensitizationView()
        case .emergency:
            EmergencyCrisisView()
        case .intentions:
            ImplementationIntentionsView()
        case .coach:
            CoachChatView()
        }
    }

    private var urgentHelpBanner: some View {
        Button {
            selectedTool = .emergency
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.emergency)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Having an urge right now?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text("Tap for immediate help")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: selectedTool)
        .padding(.top, 8)
        .accessibilityLabel("Having an urge right now? Tap for immediate help")
    }

    private var coachCard: some View {
        Button {
            showCoach = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Theme.teal.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundStyle(Theme.teal)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("AI Coach")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Your personal wellness coach — CBT, ACT & more")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: showCoach)
        .accessibilityLabel("AI Coach")
        .accessibilityHint("Open your personal wellness coach")
    }

    private var blockingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.95))
                Text("Blocking & Friction")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            Button {
                showDNSBlocking = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.25, green: 0.45, blue: 0.95).opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "shield.checkered")
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.95))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text("Block Gambling Sites")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            if blockingEnabled {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.accentGreen)
                            }
                        }
                        Text(blockingEnabled ? "DNS protection is active" : "Set up DNS-level site blocking")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    if !blockingEnabled {
                        Text("+100 XP")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.95))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.25, green: 0.45, blue: 0.95).opacity(0.12), in: .capsule)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                    }
                }
                .padding(16)
                .glassCard()
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showDNSBlocking)
            .accessibilityLabel("Block gambling sites")

            Button {
                showOneSecGuide = true
            } label: {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.78, blue: 0.4).opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "lungs.fill")
                            .font(.title3)
                            .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.4))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Add Breathing Pause")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("Pause before opening tempting apps")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Text("57%")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.4))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.2, green: 0.78, blue: 0.4).opacity(0.12), in: .capsule)
                }
                .padding(16)
                .glassCard()
            }
            .buttonStyle(PressableButtonStyle())
            .sensoryFeedback(.impact(weight: .medium), trigger: showOneSecGuide)
            .accessibilityLabel("Add breathing pause to apps")
            .accessibilityHint("Guides you to add a breathing pause before opening tempting apps")
        }
    }
}

private struct ToolCard: View {
    let tool: ToolType
    let emergencyPulse: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: tool.icon)
                    .font(.title2)
                    .foregroundStyle(tool.color)
                    .frame(width: 44, height: 44)
                    .background(tool.color.opacity(0.12), in: .rect(cornerRadius: 12))

                Text(tool.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text(tool.subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .glassCard()
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(tool.title)
        .accessibilityHint(tool.subtitle)
    }
}
