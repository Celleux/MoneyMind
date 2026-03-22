import SwiftUI
import SwiftData

struct OperationGetPaidView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var playerProfiles: [PlayerProfile]

    @State private var currentStep: Int = 0
    @State private var completedSteps: Set<Int> = []

    @State private var friendName: String = ""
    @State private var amountOwed: String = ""
    @State private var reason: DebtReason = .food
    @State private var timeElapsed: TimeElapsed = .thisWeek

    @State private var toneValue: Double = 0.5
    @State private var includeEmoji: Bool = true
    @State private var editedMessage: String = ""
    @State private var messageCopied: Bool = false

    @State private var hasSent: Bool = false
    @State private var selectedOutcome: PaymentOutcome?
    @State private var showWriteOff: Bool = false
    @State private var writeOffChoice: WriteOffChoice?

    @State private var showRewardCelebration: Bool = false
    @State private var finalReward: QuestReward?

    @State private var stepTransition: Bool = false

    private var player: PlayerProfile { playerProfiles.first ?? PlayerProfile() }

    private var parsedAmount: Double {
        Double(amountOwed.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    private var amountTier: AmountTier {
        if parsedAmount <= 50 { return .small }
        if parsedAmount <= 200 { return .medium }
        return .large
    }

    private var canProceedStep0: Bool {
        !friendName.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount > 0
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.background, Color(hex: 0x0d1a14)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    missionHeader
                        .padding(.bottom, 24)

                    timeline
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                }
                .padding(.top, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.textMuted)
                }
            }
        }
        .fullScreenCover(isPresented: $showRewardCelebration) {
            if let reward = finalReward {
                QuestRewardCelebration(reward: reward)
            }
        }
    }

    // MARK: - Mission Header

    private var missionHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 72, height: 72)

                Circle()
                    .stroke(Theme.accent.opacity(0.3), lineWidth: 2)
                    .frame(width: 72, height: 72)

                Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }

            Text("OPERATION: GET PAID")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Theme.accent)
                .tracking(3)

            Text("Recover money owed to you")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 16) {
                RewardChip(icon: "star.fill", text: "+190 XP", color: Theme.gold)
                RewardChip(icon: "trophy.fill", text: "Badge", color: Theme.accent)
                RewardChip(icon: "creditcard.fill", text: "Card", color: Color(hex: 0xA78BFA))
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Timeline

    private var timeline: some View {
        VStack(spacing: 0) {
            timelineStep(
                index: 0,
                title: "Brief the Mission",
                xp: 10,
                content: { step0Content }
            )

            timelineStep(
                index: 1,
                title: "Choose Your Approach",
                xp: 5,
                content: { step1Content }
            )

            timelineStep(
                index: 2,
                title: "Send the Request",
                xp: 25,
                content: { step2Content }
            )

            timelineStep(
                index: 3,
                title: "Track the Response",
                xp: 50,
                content: { step3Content }
            )

            timelineStep(
                index: 4,
                title: "Quest Complete",
                xp: 100,
                isLast: true,
                content: { step4Content }
            )
        }
    }

    // MARK: - Timeline Step Builder

    private func timelineStep<Content: View>(
        index: Int,
        title: String,
        xp: Int,
        isLast: Bool = false,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(stepCircleColor(index))
                        .frame(width: 36, height: 36)

                    if completedSteps.contains(index) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    } else if currentStep == index {
                        Circle()
                            .fill(Theme.accent)
                            .frame(width: 12, height: 12)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.textMuted)
                    }
                }

                if !isLast {
                    Rectangle()
                        .fill(completedSteps.contains(index) ? Theme.accent.opacity(0.4) : Theme.elevated)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(currentStep >= index ? .white : Theme.textMuted)

                    Spacer()

                    Text("+\(xp) XP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(completedSteps.contains(index) ? Theme.accent : Theme.gold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(
                                completedSteps.contains(index) ? Theme.accent.opacity(0.15) : Theme.gold.opacity(0.1)
                            )
                        )
                }

                if completedSteps.contains(index) && currentStep != index {
                    completedSummary(for: index)
                } else if currentStep == index {
                    content()
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, isLast ? 0 : 24)
        }
    }

    private func stepCircleColor(_ index: Int) -> Color {
        if completedSteps.contains(index) { return Theme.accent }
        if currentStep == index { return Theme.accent.opacity(0.2) }
        return Theme.elevated
    }

    // MARK: - Completed Summaries

    @ViewBuilder
    private func completedSummary(for index: Int) -> some View {
        switch index {
        case 0:
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textMuted)
                Text("\(friendName) · \(formattedAmount) · \(reason.rawValue)")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
            }
        case 1:
            Text("Message prepared")
                .font(.system(size: 11))
                .foregroundStyle(Theme.textSecondary)
        case 2:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.accent)
                Text("Request sent")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
            }
        case 3:
            if let outcome = selectedOutcome {
                Text(outcome.summaryText)
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Step 0: Brief the Mission

    private var step0Content: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.accent)
                Text("The average American is owed $926 by friends and family")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.accent.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Theme.accent.opacity(0.15), lineWidth: 0.5)
                    )
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("Who owes you?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                TextField("Friend's name", text: $friendName)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.elevated)
                    )
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("How much?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                HStack(spacing: 8) {
                    Text("$")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.accent)

                    TextField("0", text: $amountOwed)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .keyboardType(.decimalPad)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.elevated)
                )

                if parsedAmount > 0 {
                    Text(amountTier.label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(amountTier.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(amountTier.color.opacity(0.12)))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("What for?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(DebtReason.allCases, id: \.self) { r in
                            Button {
                                reason = r
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: r.icon)
                                        .font(.system(size: 12))
                                    Text(r.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundStyle(reason == r ? Theme.background : Theme.textSecondary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(reason == r ? Theme.accent : Theme.elevated)
                                )
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("How long ago?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(TimeElapsed.allCases, id: \.self) { t in
                            Button {
                                timeElapsed = t
                            } label: {
                                Text(t.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(timeElapsed == t ? Theme.background : Theme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(timeElapsed == t ? Theme.accent : Theme.elevated)
                                    )
                            }
                        }
                    }
                }
            }

            stepButton(text: "Continue", enabled: canProceedStep0) {
                completeStep(0)
                editedMessage = generateMessage()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.elevated.opacity(0.5), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Step 1: Choose Your Approach

    private var step1Content: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tone")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                HStack {
                    Text("Casual")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                    Slider(value: $toneValue, in: 0...1)
                        .tint(Theme.accent)
                        .onChange(of: toneValue) { _, _ in
                            editedMessage = generateMessage()
                        }
                    Text("Direct")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.textMuted)
                }

                Toggle(isOn: $includeEmoji) {
                    Text("Include emoji")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .tint(Theme.accent)
                .onChange(of: includeEmoji) { _, _ in
                    editedMessage = generateMessage()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Your message")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Button {
                        editedMessage = generateMessage()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 10))
                            Text("Reset")
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundStyle(Theme.textMuted)
                    }
                }

                chatBubble
            }

            HStack(spacing: 8) {
                ForEach(ScriptVariant.allCases, id: \.self) { variant in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            editedMessage = generateScript(variant: variant)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: variant.icon)
                                .font(.system(size: 16))
                            Text(variant.rawValue)
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Theme.elevated)
                        )
                    }
                }
            }

            stepButton(text: "Message Ready", enabled: !editedMessage.isEmpty) {
                completeStep(1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.elevated.opacity(0.5), lineWidth: 0.5)
                )
        )
    }

    private var chatBubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $editedMessage)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80, maxHeight: 160)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: 0x1E3A2F))
        )
        .overlay(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Theme.accent)
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(45))
                .offset(x: -16, y: 6)
        }
    }

    // MARK: - Step 2: Send the Request

    private var step2Content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !hasSent {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose how to send")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)

                    sendOptionButton(
                        icon: "message.fill",
                        title: "iMessage",
                        subtitle: "Send as a text message",
                        color: Color(hex: 0x34C759)
                    ) {
                        openIMessage()
                    }

                    sendOptionButton(
                        icon: "v.circle.fill",
                        title: "Venmo",
                        subtitle: "Request via Venmo",
                        color: Color(hex: 0x3D95CE)
                    ) {
                        openVenmo()
                    }

                    sendOptionButton(
                        icon: "p.circle.fill",
                        title: "PayPal",
                        subtitle: "Send a PayPal.me link",
                        color: Color(hex: 0x003087)
                    ) {
                        openPayPal()
                    }

                    sendOptionButton(
                        icon: "doc.on.doc.fill",
                        title: "Copy to Clipboard",
                        subtitle: messageCopied ? "Copied" : "Copy message text",
                        color: Theme.textSecondary
                    ) {
                        copyMessage()
                    }
                }

                Divider().background(Theme.elevated)

                Button {
                    withAnimation(Theme.spring) {
                        hasSent = true
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } label: {
                    Text("I've sent the request")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.accent.opacity(0.4), lineWidth: 1)
                        )
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.accent)

                    Text("The hardest part is over")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Most people pay back within 24 hours. You showed real courage by asking.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

                stepButton(text: "Continue", enabled: true) {
                    completeStep(2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.elevated.opacity(0.5), lineWidth: 0.5)
                )
        )
    }

    private func sendOptionButton(
        icon: String,
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textMuted)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textMuted)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.elevated)
            )
        }
    }

    // MARK: - Step 3: Track the Response

    private var step3Content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if showWriteOff {
                writeOffContent
            } else if selectedOutcome == nil {
                Text("What happened?")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                outcomeButton(
                    outcome: .paidFull,
                    icon: "checkmark.circle.fill",
                    title: "They paid me back",
                    subtitle: "Full amount received",
                    color: Theme.accent
                )

                outcomeButton(
                    outcome: .paidPartial,
                    icon: "circle.lefthalf.filled",
                    title: "Partial payment",
                    subtitle: "They paid some of it",
                    color: Theme.gold
                )

                outcomeButton(
                    outcome: .noResponse,
                    icon: "clock.fill",
                    title: "No response yet",
                    subtitle: "Still waiting to hear back",
                    color: Color(hex: 0x60A5FA)
                )

                outcomeButton(
                    outcome: .cantPay,
                    icon: "exclamationmark.circle.fill",
                    title: "They can't pay now",
                    subtitle: "Need a payment plan",
                    color: Color(hex: 0xFB923C)
                )

                outcomeButton(
                    outcome: .refused,
                    icon: "xmark.circle.fill",
                    title: "They refused",
                    subtitle: "It didn't work out",
                    color: Theme.textMuted
                )

                archiveButton
            } else {
                outcomeResultContent
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.elevated.opacity(0.5), lineWidth: 0.5)
                )
        )
    }

    private func outcomeButton(
        outcome: PaymentOutcome,
        icon: String,
        title: String,
        subtitle: String,
        color: Color
    ) -> some View {
        Button {
            withAnimation(Theme.spring) {
                selectedOutcome = outcome
                if outcome == .refused {
                    showWriteOff = true
                    selectedOutcome = nil
                }
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textMuted)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.elevated)
            )
        }
    }

    @ViewBuilder
    private var outcomeResultContent: some View {
        switch selectedOutcome {
        case .paidFull:
            VStack(spacing: 12) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Theme.gold)

                Text("You recovered \(formattedAmount)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text(impactComparison)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                stepButton(text: "Claim Reward", enabled: true) {
                    completeStep(3)
                }
            }
            .frame(maxWidth: .infinity)

        case .paidPartial:
            VStack(alignment: .leading, spacing: 12) {
                Text("Progress is progress. You took action and got a result.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)

                stepButton(text: "Continue", enabled: true) {
                    completeStep(3)
                }
            }

        case .noResponse:
            VStack(alignment: .leading, spacing: 12) {
                Text("Follow-up script")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                Text(followUpScript)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.elevated)
                    )

                Text("Send this in 2-3 days if you haven't heard back. Persistence is not rude — it's responsible.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textMuted)

                stepButton(text: "Continue", enabled: true) {
                    completeStep(3)
                }
            }

        case .cantPay:
            VStack(alignment: .leading, spacing: 12) {
                Text("Payment plan template")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)

                Text(paymentPlanScript)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.elevated)
                    )

                Button {
                    UIPasteboard.general.string = paymentPlanScript
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 12))
                        Text("Copy plan")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(Theme.accent)
                }

                stepButton(text: "Continue", enabled: true) {
                    completeStep(3)
                }
            }

        default:
            EmptyView()
        }
    }

    // MARK: - Write-Off Decision

    private var writeOffContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sometimes it doesn't work out. That's okay — you tried, and that took courage.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.textSecondary)

            VStack(spacing: 10) {
                Button {
                    withAnimation(Theme.spring) { writeOffChoice = .gift }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: 0xF472B6))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("The Write-Off Decision")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Mark as a gift for emotional closure (+15 XP)")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        if writeOffChoice == .gift {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(writeOffChoice == .gift ? Theme.accent.opacity(0.1) : Theme.elevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(writeOffChoice == .gift ? Theme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }

                Button {
                    withAnimation(Theme.spring) { writeOffChoice = .boundary }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(hex: 0x60A5FA))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Set a Lending Boundary")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Decide your lending limit for next time (+10 XP)")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        if writeOffChoice == .boundary {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(writeOffChoice == .boundary ? Theme.accent.opacity(0.1) : Theme.elevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(writeOffChoice == .boundary ? Theme.accent.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                    )
                }
            }

            if writeOffChoice != nil {
                stepButton(text: "Accept with Wisdom", enabled: true) {
                    selectedOutcome = .refused
                    completeStep(3)
                }
            }
        }
    }

    private var archiveButton: some View {
        Button {
            archiveQuest()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "archivebox")
                    .font(.system(size: 12))
                Text("Archive this quest — no penalty")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundStyle(Theme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
    }

    // MARK: - Step 4: Quest Complete

    private var step4Content: some View {
        VStack(spacing: 16) {
            if selectedOutcome == .refused || writeOffChoice != nil {
                VStack(spacing: 12) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(hex: 0xA78BFA))

                    Text("Financial Wisdom Earned")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Text("You faced a difficult conversation. That takes real courage, regardless of the outcome.")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Theme.gold)
                        .symbolEffect(.bounce)

                    Text("Quest Complete")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    if parsedAmount > 0 {
                        Text("You recovered \(formattedAmount)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.accent)

                        Text(impactComparison)
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            Button {
                finishQuest()
            } label: {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18, weight: .bold))
                    Text("Claim Rewards")
                        .font(.system(size: 16, weight: .black))
                }
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Theme.accent.opacity(0.4), radius: 12, y: 4)
            }

            ShareLink(
                item: shareText,
                subject: Text("I recovered money with Splurj"),
                message: Text(shareText)
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12))
                    Text("Share your win")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.elevated.opacity(0.5), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Shared Step Button

    private func stepButton(text: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            Text(text)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(enabled ? Theme.background : Theme.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 11)
                        .fill(enabled ? Theme.accent : Theme.elevated)
                )
        }
        .disabled(!enabled)
    }

    // MARK: - Actions

    private func completeStep(_ step: Int) {
        withAnimation(Theme.spring) {
            completedSteps.insert(step)
            if step < 4 {
                currentStep = step + 1
            }
        }
    }

    private func archiveQuest() {
        let engine = QuestEngine(modelContext: modelContext)
        engine.archiveQuest("recovery_ask_friend", player: player)
        dismiss()
    }

    private func finishQuest() {
        let engine = QuestEngine(modelContext: modelContext)
        let reward = engine.completeQuest("recovery_ask_friend", player: player)

        player.totalMoneyRecovered += parsedAmount

        var badges = player.unlockedBadges
        if !badges.contains("Debt Collector") {
            badges.append("Debt Collector")
            player.unlockedBadges = badges
        }

        try? modelContext.save()

        finalReward = reward
        showRewardCelebration = true
    }

    // MARK: - Deep Links

    private func openIMessage() {
        let encoded = editedMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "sms:&body=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }

    private func openVenmo() {
        if let url = URL(string: "venmo://paycharge") {
            UIApplication.shared.open(url) { success in
                if !success {
                    if let webURL = URL(string: "https://venmo.com") {
                        UIApplication.shared.open(webURL)
                    }
                }
            }
        }
    }

    private func openPayPal() {
        if let url = URL(string: "https://paypal.me") {
            UIApplication.shared.open(url)
        }
    }

    private func copyMessage() {
        UIPasteboard.general.string = editedMessage
        messageCopied = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            messageCopied = false
        }
    }

    // MARK: - Message Generation

    private func generateMessage() -> String {
        generateScript(variant: .friendly)
    }

    private func generateScript(variant: ScriptVariant) -> String {
        let name = friendName.isEmpty ? "there" : friendName
        let amt = formattedAmount
        let emoji = includeEmoji

        let casual = toneValue < 0.35
        let direct = toneValue > 0.65

        switch amountTier {
        case .small:
            switch variant {
            case .friendly:
                if casual {
                    return "Hey \(name)! \(emoji ? "😊 " : "")Your share from \(reason.context) was \(amt). Here's my Venmo whenever you get a sec\(emoji ? " 🙏" : "")"
                } else if direct {
                    return "Hi \(name), just a reminder — you owe me \(amt) from \(reason.context). Can you send it over today?"
                }
                return "Hey \(name)\(emoji ? " 👋" : ""), your share from \(reason.context) was \(amt). Easy to split whenever you get a chance"
            case .humorous:
                return "Hey \(name)\(emoji ? " 😄" : ""), my bank account told me to remind you about that \(amt) from \(reason.context). It's been very persistent"
            case .professional:
                return "Hi \(name), following up on the \(amt) from \(reason.context). Would appreciate if you could send it when convenient"
            }

        case .medium:
            switch variant {
            case .friendly:
                if casual {
                    return "Hey \(name)! \(emoji ? "😊 " : "")Had such a great time\(reason == .event ? " at the event" : ""). The expense breakdown comes to \(amt) for your share. Easy to split through Venmo\(emoji ? " 💸" : "")"
                } else if direct {
                    return "Hi \(name), the total for \(reason.context) was \(amt) on your end. Can you send that over this week?"
                }
                return "Hey \(name)\(emoji ? " 👋" : ""), here's the breakdown from \(reason.context) — your share comes to \(amt). Easy to send through Venmo whenever works"
            case .humorous:
                return "\(name)\(emoji ? " 😅" : ""), remember \(reason.context)? Great times. My wallet remembers too — \(amt) worth of memories. Send when you can"
            case .professional:
                return "Hi \(name), I've tallied up the expenses from \(reason.context). Your portion comes to \(amt). Let me know the best way to settle up"
            }

        case .large:
            switch variant {
            case .friendly:
                if casual {
                    return "Hey \(name), I wanted to chat about the \(amt) from \(reason.context). No rush on a lump sum — we can split it into payments if that's easier\(emoji ? " 🤝" : "")"
                } else if direct {
                    return "Hi \(name), I'd like to work out a plan for the \(amt) from \(reason.context). Can we figure out a payment schedule that works for both of us?"
                }
                return "Hey \(name)\(emoji ? " 👋" : ""), wanted to bring up the \(amt) from \(reason.context). I know it's a bigger amount — happy to work out a plan if that helps"
            case .humorous:
                return "Hey \(name), so about that \(amt) from \(reason.context)\(emoji ? " 😬" : ""). I promise I won't charge interest... yet. Can we figure something out?"
            case .professional:
                return "Hi \(name), I'd like to discuss the \(amt) from \(reason.context). I'm open to setting up a payment plan if paying all at once isn't feasible right now"
            }
        }
    }

    private var followUpScript: String {
        let name = friendName.isEmpty ? "there" : friendName
        let amt = formattedAmount
        return "Hey \(name), just following up on the \(amt) — wanted to make sure my earlier message didn't get lost. Any chance you can send it over this week?"
    }

    private var paymentPlanScript: String {
        let name = friendName.isEmpty ? "there" : friendName
        let amt = formattedAmount
        let half = formattedHalf
        return "Hey \(name), totally understand if \(amt) all at once is tough right now. Would it work to split it into two payments of \(half)? First one whenever you can, second one next month?"
    }

    // MARK: - Computed

    private var formattedAmount: String {
        let val = parsedAmount
        if val == floor(val) {
            return "$\(Int(val))"
        }
        return String(format: "$%.2f", val)
    }

    private var formattedHalf: String {
        let val = parsedAmount / 2
        if val == floor(val) {
            return "$\(Int(val))"
        }
        return String(format: "$%.2f", val)
    }

    private var impactComparison: String {
        let amt = parsedAmount
        let lattes = Int(amt / 6)
        let groceryDays = Int(amt / 15)
        if lattes > 0 && groceryDays > 0 {
            return "That's \(lattes) lattes or \(groceryDays) days of groceries"
        }
        return "Every dollar recovered counts"
    }

    private var shareText: String {
        "I just used Splurj to recover \(formattedAmount) that a friend owed me. The app gave me a quest with a pre-written script and I actually did it. No awkwardness, just results."
    }
}

// MARK: - Supporting Types

private enum DebtReason: String, CaseIterable {
    case food = "Food"
    case rent = "Rent"
    case event = "Event"
    case travel = "Travel"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .rent: return "house.fill"
        case .event: return "ticket.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var context: String {
        switch self {
        case .food: return "dinner"
        case .rent: return "rent"
        case .event: return "the event"
        case .travel: return "the trip"
        case .other: return "our expenses"
        }
    }
}

private enum TimeElapsed: String, CaseIterable {
    case thisWeek = "This week"
    case lastWeek = "Last week"
    case twoWeeks = "2 weeks"
    case oneMonth = "1 month+"
    case overThree = "3+ months"
}

private enum AmountTier {
    case small, medium, large

    var label: String {
        switch self {
        case .small: return "Quick ask"
        case .medium: return "Standard request"
        case .large: return "Conversation needed"
        }
    }

    var color: Color {
        switch self {
        case .small: return Theme.accent
        case .medium: return Color(hex: 0x60A5FA)
        case .large: return Color(hex: 0xFB923C)
        }
    }
}

private enum PaymentOutcome {
    case paidFull
    case paidPartial
    case noResponse
    case cantPay
    case refused

    var summaryText: String {
        switch self {
        case .paidFull: return "Paid in full"
        case .paidPartial: return "Partial payment"
        case .noResponse: return "Follow-up sent"
        case .cantPay: return "Payment plan set"
        case .refused: return "Wisdom earned"
        }
    }
}

private enum WriteOffChoice {
    case gift
    case boundary
}

private enum ScriptVariant: String, CaseIterable {
    case friendly = "Friendly"
    case humorous = "Funny"
    case professional = "Pro"

    var icon: String {
        switch self {
        case .friendly: return "face.smiling"
        case .humorous: return "theatermask.and.paintbrush"
        case .professional: return "briefcase.fill"
        }
    }
}
