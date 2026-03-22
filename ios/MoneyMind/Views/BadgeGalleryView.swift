import SwiftUI
import SwiftData

struct BadgeGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var badges: [Badge]
    @State private var selectedCategory: BadgeCategory = .money
    @State private var selectedBadgeName: String?

    private func badgesForCategory(_ category: BadgeCategory) -> [Badge] {
        badges.filter { $0.category == category.rawValue }
    }

    private var selectedBadge: Badge? {
        guard let name = selectedBadgeName else { return nil }
        return badges.first { $0.name == name }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "medal.fill")
                    .foregroundStyle(Theme.gold)
                Text("Badges")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                let earnedCount = badges.filter(\.isEarned).count
                Text("\(earnedCount)/\(badges.count)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            Picker("Category", selection: $selectedCategory) {
                ForEach(BadgeCategory.allCases, id: \.self) { cat in
                    Text(cat.rawValue).tag(cat)
                }
            }
            .pickerStyle(.segmented)

            let categoryBadges = badgesForCategory(selectedCategory)
            if categoryBadges.isEmpty {
                Text("No badges in this category yet")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(categoryBadges, id: \.name) { badge in
                        BadgeCellView(badge: badge) {
                            if badge.isEarned {
                                selectedBadgeName = badge.name
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Theme.gold.opacity(0.1), lineWidth: 1)
        )
        .sheet(isPresented: Binding(
            get: { selectedBadgeName != nil },
            set: { if !$0 { selectedBadgeName = nil } }
        )) {
            if let badge = selectedBadge {
                BadgeDetailSheetView(badge: badge)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            seedBadgesIfNeeded()
        }
    }

    private func seedBadgesIfNeeded() {
        guard badges.isEmpty else { return }
        for info in BadgeDefinition.all {
            let badge = Badge(name: info.name, category: info.category, badgeDescription: info.description, iconName: info.icon)
            modelContext.insert(badge)
        }
    }
}

private struct BadgeCellView: View {
    let badge: Badge
    let action: () -> Void

    private var badgeColor: Color {
        switch badge.category {
        case "Money": Theme.accentGreen
        case "Streak": .orange
        case "Skill": Theme.teal
        default: Theme.textSecondary
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(badge.isEarned ? badgeColor.opacity(0.15) : Theme.textSecondary.opacity(0.05))
                        .frame(width: 52, height: 52)

                    if badge.isEarned {
                        Circle()
                            .fill(badgeColor.opacity(0.08))
                            .frame(width: 64, height: 64)
                    }

                    Image(systemName: badge.iconName)
                        .font(.title3)
                        .foregroundStyle(badge.isEarned ? badgeColor : Theme.textSecondary.opacity(0.25))

                    if !badge.isEarned {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary.opacity(0.4))
                            .offset(x: 16, y: 16)
                    }
                }

                Text(badge.name)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(badge.isEarned ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(badge.name), \(badge.isEarned ? "earned" : "locked")")
    }
}

private struct BadgeDetailSheetView: View {
    let badge: Badge

    private var badgeColor: Color {
        switch badge.category {
        case "Money": Theme.accentGreen
        case "Streak": .orange
        case "Skill": Theme.teal
        default: Theme.textSecondary
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 88, height: 88)
                Circle()
                    .fill(badgeColor.opacity(0.06))
                    .frame(width: 104, height: 104)
                Image(systemName: badge.iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(badgeColor)
            }

            Text(badge.name)
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)

            Text(badge.badgeDescription)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            if let date = badge.dateEarned {
                Label("Earned \(date, format: .dateTime.month(.wide).day().year())", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(badge.category)
                .font(.caption.weight(.semibold))
                .foregroundStyle(badgeColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(badgeColor.opacity(0.12), in: .capsule)

            ShareLink(
                item: "I earned the \"\(badge.name)\" badge on MoneyMind! \(badge.badgeDescription)",
                subject: Text("MoneyMind Badge"),
                message: Text("Check out my achievement!")
            ) {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(badgeColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(badgeColor.opacity(0.1), in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(24)
    }
}
