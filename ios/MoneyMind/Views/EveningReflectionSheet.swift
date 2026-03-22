import SwiftUI
import SwiftData

struct EveningReflectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \ImpulseLog.date, order: .reverse) private var impulseLogs: [ImpulseLog]

    @State private var starRating: Int = 3
    @State private var selectedTriggers: Set<String> = []
    @State private var urgeIntensity: Double = 3
    @State private var submitted = false

    private var profile: UserProfile? { profiles.first }

    private let triggers = ["Boredom", "Stress", "Social Pressure", "FOMO", "Habit", "Reward", "Loneliness"]

    private var todaySaved: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return impulseLogs.filter { $0.resisted && $0.date >= today }.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    starsSection
                    triggersSection
                    urgeSliderSection
                    savedTodaySection
                    submitButton
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Evening Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private var starsSection: some View {
        VStack(spacing: 12) {
            Text("How was your day?")
                .font(Theme.headingFont(.title3))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            starRating = star
                        }
                    } label: {
                        Image(systemName: star <= starRating ? "star.fill" : "star")
                            .font(.system(size: 36))
                            .foregroundStyle(star <= starRating ? Theme.gold : Theme.textSecondary.opacity(0.3))
                            .scaleEffect(star <= starRating ? 1.1 : 1.0)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: starRating)
                    .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var triggersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Any triggers today?")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            FlowLayout(spacing: 8) {
                ForEach(triggers, id: \.self) { trigger in
                    let isSelected = selectedTriggers.contains(trigger)
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            if isSelected {
                                selectedTriggers.remove(trigger)
                            } else {
                                selectedTriggers.insert(trigger)
                            }
                        }
                    } label: {
                        Text(trigger)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(isSelected ? Theme.background : Theme.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                isSelected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.cardSurface),
                                in: .capsule
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(isSelected ? Theme.accentGreen.opacity(0.3) : Theme.textSecondary.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .sensoryFeedback(.selection, trigger: isSelected)
                    .accessibilityLabel("\(trigger)\(isSelected ? ", selected" : "")")
                }
            }
        }
    }

    private var urgeSliderSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Urge intensity")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(String(format: "%.0f", urgeIntensity))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(urgeColor)
                    .contentTransition(.numericText())
            }

            Slider(value: $urgeIntensity, in: 0...10, step: 0.1)
                .tint(urgeColor)
                .accessibilityLabel("Urge intensity slider")

            HStack {
                Text("None")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Extreme")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }

    private var urgeColor: Color {
        switch urgeIntensity {
        case 0..<3: Theme.accentGreen
        case 3..<6: Theme.gold
        case 6..<8: .orange
        default: Theme.emergency
        }
    }

    private var savedTodaySection: some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .font(.title2)
                .foregroundStyle(Theme.accentGreen)
            VStack(alignment: .leading, spacing: 2) {
                Text("Money saved today")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Text(todaySaved, format: .currency(code: "USD"))
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.accentGreen.opacity(0.08), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.accentGreen.opacity(0.12), lineWidth: 1)
        )
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            Text("Save Reflection")
                .font(.headline)
                .foregroundStyle(Theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.success, trigger: submitted)
        .accessibilityLabel("Save evening reflection")
    }

    private func submit() {
        let reflection = EveningReflection(
            starRating: starRating,
            triggers: Array(selectedTriggers),
            urgeIntensity: urgeIntensity,
            moneySavedToday: todaySaved
        )
        modelContext.insert(reflection)

        if let profile {
            profile.xpPoints += XPAction.dailyCheckIn.xpValue
            profile.totalConsciousChoices += 1
        }

        submitted = true

        Task {
            let healthVM = HealthViewModel()
            await healthVM.saveStateOfMind(starRating: starRating)
        }

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            dismiss()
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x - spacing)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
