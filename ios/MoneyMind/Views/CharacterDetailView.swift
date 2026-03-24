import SwiftUI
import SwiftData

struct CharacterDetailView: View {
    @Query private var profiles: [UserProfile]
    @Query private var impulseLogs: [ImpulseLog]

    private var profile: UserProfile? { profiles.first }

    private var characterStage: CharacterStage {
        CharacterStage.from(xp: profile?.xpPoints ?? 0)
    }

    private var characterLevel: Int {
        CharacterStage.level(from: profile?.xpPoints ?? 0)
    }

    private var dayCount: Int {
        guard let start = profile?.startDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
    }

    private var xpProgress: Double {
        let xp = profile?.xpPoints ?? 0
        let lvl = CharacterStage.level(from: xp)
        let cur = CharacterStage.xpForLevel(lvl)
        let nxt = CharacterStage.xpForNextLevel(lvl)
        let range = nxt - cur
        guard range > 0 else { return 1.0 }
        return Double(xp - cur) / Double(range)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                CharacterView(stage: characterStage, reaction: .idle, level: characterLevel)
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Text(characterStage.name)
                        .font(Typography.displayMedium)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Level \(characterLevel)")
                        .font(Typography.headingLarge)
                        .foregroundStyle(Theme.accent)
                }

                VStack(spacing: 8) {
                    XPProgressBar(
                        progress: xpProgress,
                        level: characterLevel,
                        stage: characterStage,
                        currentXP: profile?.xpPoints ?? 0
                    )

                    Text("\(profile?.xpPoints ?? 0) XP")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    characterStat(value: "\(profile?.currentStreak ?? 0)", label: "Streak", icon: "flame.fill")
                    characterStat(
                        value: (profile?.totalSaved ?? 0).formatted(.currency(code: profile?.defaultCurrency ?? "USD").precision(.fractionLength(0))),
                        label: "Saved",
                        icon: "dollarsign.circle.fill"
                    )
                    characterStat(value: "\(dayCount)", label: "Days", icon: "calendar")
                }
                .padding(.horizontal)

                ShareCharacterButton(
                    stage: characterStage,
                    level: characterLevel,
                    totalSaved: profile?.totalSaved ?? 0,
                    streak: profile?.currentStreak ?? 0,
                    dayCount: dayCount
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text("Evolution Path")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(CharacterStage.allCases, id: \.rawValue) { stage in
                        HStack(spacing: 12) {
                            Image(systemName: stage.bodyIcon)
                                .font(Typography.headingLarge)
                                .foregroundStyle(stage == characterStage ? Theme.accent : Theme.textMuted)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(stage.name)
                                    .font(Typography.bodyMedium)
                                    .foregroundStyle(stage == characterStage ? Theme.textPrimary : Theme.textSecondary)
                                Text("Level \(stage.levelRange.lowerBound)–\(stage.levelRange.upperBound)")
                                    .font(Typography.labelSmall)
                                    .foregroundStyle(Theme.textMuted)
                            }

                            Spacer()

                            if stage.rawValue < characterStage.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accent)
                            } else if stage == characterStage {
                                Text("CURRENT")
                                    .font(Typography.labelSmall)
                                    .foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Theme.accent.opacity(0.12), in: .capsule)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(16)
                .splurjCard(.elevated)
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("My Character")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func characterStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(Typography.headingLarge)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .splurjCard(.outlined)
    }
}
