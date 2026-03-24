import SwiftUI
import SwiftData

struct EMACheckInCard: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EMACheckIn.timestamp, order: .reverse) private var checkIns: [EMACheckIn]
    @Query private var profiles: [UserProfile]

    @State private var urgeLevel: Float = 5
    @State private var spendingIntention: String = ""
    @State private var stuckToIntention: Bool = true
    @State private var selectedMood: String = ""
    @State private var plannedAmount: String = ""
    @State private var submitted = false

    private var profile: UserProfile? { profiles.first }

    private var currentCheckInType: EMACheckInType? {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 7..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return nil
        }
    }

    private var hasCompletedCurrentWindow: Bool {
        guard let type = currentCheckInType else { return true }
        let today = Calendar.current.startOfDay(for: Date())
        return checkIns.contains { $0.typeRaw == type.rawValue && $0.timestamp >= today }
    }

    private let moods = ["😊", "😐", "😔", "😤", "😰", "😴"]

    var body: some View {
        if let type = currentCheckInType, !hasCompletedCurrentWindow, !submitted {
            VStack(spacing: 16) {
                headerForType(type)

                switch type {
                case .morning:
                    morningContent
                case .afternoon:
                    afternoonContent
                case .evening:
                    eveningContent
                }

                submitButton(for: type)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [colorForType(type).opacity(0.08), Theme.cardSurface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(colorForType(type).opacity(0.15), lineWidth: 1)
            )
        }
    }

    private func headerForType(_ type: EMACheckInType) -> some View {
        HStack(spacing: 10) {
            Image(systemName: iconForType(type))
                .font(Typography.headingLarge)
                .foregroundStyle(colorForType(type))
            VStack(alignment: .leading, spacing: 2) {
                Text(titleForType(type))
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textPrimary)
                Text("In the past few hours")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Text("~45s")
                .font(Typography.labelSmall)
                .foregroundStyle(colorForType(type))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(colorForType(type).opacity(0.12), in: .capsule)
        }
    }

    private var morningContent: some View {
        VStack(spacing: 12) {
            Text("How's your urge level right now?")
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textPrimary)

            HStack {
                Text(String(format: "%.1f", urgeLevel))
                    .font(Typography.displaySmall)
                    .foregroundStyle(urgeColor)
                    .frame(width: 50)
                    .contentTransition(.numericText())
                Slider(value: Binding(get: { Double(urgeLevel) }, set: { urgeLevel = Float($0) }), in: 0...10, step: 0.1)
                    .tint(urgeColor)
            }

            HStack {
                Text("None")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Extreme")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
    }

    private var afternoonContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any purchases planned today?")
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textPrimary)

            let options = ["No spending", "Feeling tempted"]
            ForEach(options, id: \.self) { option in
                let isSelected = spendingIntention == option
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        spendingIntention = option
                    }
                } label: {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? Theme.accentGreen : Theme.textSecondary.opacity(0.4))
                        Text(option)
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                    }
                    .padding(12)
                    .background(isSelected ? Theme.accentGreen.opacity(0.08) : Theme.cardSurface.opacity(0.5), in: .rect(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: spendingIntention)
                .accessibilityLabel("\(option)\(isSelected ? ", selected" : "")")
            }

            Button {
                withAnimation(.spring(response: 0.3)) {
                    spendingIntention = "Planned"
                }
            } label: {
                HStack {
                    Image(systemName: spendingIntention == "Planned" ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(spendingIntention == "Planned" ? Theme.accentGreen : Theme.textSecondary.opacity(0.4))
                    Text("Planned:")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textPrimary)
                    TextField("$0", text: $plannedAmount)
                        .keyboardType(.decimalPad)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 60)
                    Spacer()
                }
                .padding(12)
                .background(spendingIntention == "Planned" ? Theme.accentGreen.opacity(0.08) : Theme.cardSurface.opacity(0.5), in: .rect(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private var eveningContent: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Did you stick to your intention?")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { stuckToIntention = true }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(Typography.labelSmall)
                            Text("Yes")
                                .font(Typography.bodyMedium)
                        }
                        .foregroundStyle(stuckToIntention ? Theme.background : Theme.accentGreen)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(stuckToIntention ? Theme.accentGreen : Theme.accentGreen.opacity(0.1), in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: stuckToIntention)

                    Button {
                        withAnimation(.spring(response: 0.3)) { stuckToIntention = false }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(Typography.labelSmall)
                            Text("No")
                                .font(Typography.bodyMedium)
                        }
                        .foregroundStyle(!stuckToIntention ? .white : Theme.emergency)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(!stuckToIntention ? Theme.emergency : Theme.emergency.opacity(0.1), in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            VStack(spacing: 8) {
                Text("How are you feeling?")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)

                HStack(spacing: 16) {
                    ForEach(moods, id: \.self) { mood in
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedMood = mood
                            }
                        } label: {
                            Text(mood)
                                .font(Typography.displayMedium)
                                .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                                .opacity(selectedMood.isEmpty || selectedMood == mood ? 1 : 0.4)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.selection, trigger: selectedMood)
                        .accessibilityLabel("Mood: \(mood)")
                    }
                }
            }
        }
    }

    private func submitButton(for type: EMACheckInType) -> some View {
        Button {
            submitCheckIn(type: type)
        } label: {
            Text("Done")
                .font(Typography.headingSmall)
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(colorForType(type), in: .rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: submitted)
        .accessibilityLabel("Submit check-in")
    }

    private func submitCheckIn(type: EMACheckInType) {
        let intention: String
        if type == .afternoon {
            intention = spendingIntention == "Planned" ? "Planned: $\(plannedAmount)" : spendingIntention
        } else {
            intention = spendingIntention
        }

        let checkIn = EMACheckIn(
            type: type,
            urgeLevel: type == .morning ? urgeLevel : 0,
            mood: selectedMood,
            spendingIntention: intention,
            stuckToIntention: stuckToIntention
        )
        modelContext.insert(checkIn)

        withAnimation(.spring(response: 0.4)) {
            submitted = true
        }
    }

    private var urgeColor: Color {
        switch urgeLevel {
        case 0..<3: Theme.accentGreen
        case 3..<6: Theme.gold
        case 6..<8: .orange
        default: Theme.emergency
        }
    }

    private func iconForType(_ type: EMACheckInType) -> String {
        switch type {
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "moon.fill"
        }
    }

    private func titleForType(_ type: EMACheckInType) -> String {
        switch type {
        case .morning: "Morning Check-In"
        case .afternoon: "Afternoon Check"
        case .evening: "Evening Check-In"
        }
    }

    private func colorForType(_ type: EMACheckInType) -> Color {
        switch type {
        case .morning: Theme.gold
        case .afternoon: Theme.teal
        case .evening: Color(red: 0.4, green: 0.5, blue: 0.9)
        }
    }
}
