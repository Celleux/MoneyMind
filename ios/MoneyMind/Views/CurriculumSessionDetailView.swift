import SwiftUI
import SwiftData

struct CurriculumSessionDetailView: View {
    let sessionNumber: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CurriculumSession.sessionNumber) private var sessions: [CurriculumSession]
    @Query private var profiles: [UserProfile]

    @State private var reflectionText: String = ""
    @State private var showCompletion = false
    @State private var showProgramCertificate = false
    @State private var currentSectionIndex: Int = 0

    private var profile: UserProfile? { profiles.first }

    private var allSessionsCompleted: Bool {
        let completedNumbers = Set(sessions.filter(\.isCompleted).map(\.sessionNumber))
        return (1...8).allSatisfy { completedNumbers.contains($0) }
    }

    private var content: CurriculumSessionContent? {
        CurriculumContent.session(for: sessionNumber)
    }

    private var existingSession: CurriculumSession? {
        sessions.first { $0.sessionNumber == sessionNumber }
    }

    private var isAlreadyCompleted: Bool {
        existingSession?.isCompleted ?? false
    }

    private var accentColor: Color {
        guard let content else { return Theme.teal }
        switch content.color {
        case "teal": return Theme.teal
        case "gold": return Theme.gold
        case "green": return Theme.accentGreen
        case "emergency": return Theme.emergency
        case "purple": return Color(red: 0.55, green: 0.3, blue: 0.85)
        default: return Theme.teal
        }
    }

    var body: some View {
        ScrollView {
            if let content {
                VStack(spacing: 28) {
                    headerSection(content)

                    ForEach(Array(content.sections.enumerated()), id: \.offset) { index, section in
                        sectionCard(section, index: index)
                    }

                    takeawaysSection(content)
                    reflectionSection(content)

                    if !isAlreadyCompleted {
                        completeButton
                    } else {
                        completedBadge
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .padding(.top, 8)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(content?.title ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showCompletion) {
            completionSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showProgramCertificate) {
            ProgramCertificateSheet(userName: profile?.name ?? "Graduate", completionDate: Date(), characterStage: CharacterStage.from(xp: profile?.xpPoints ?? 0))
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private func headerSection(_ content: CurriculumSessionContent) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: content.iconName)
                    .font(.system(size: 32))
                    .foregroundStyle(accentColor)
            }

            Text("Session \(content.number)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(accentColor)

            Text(content.title)
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)
                .multilineTextAlignment(.center)

            Text(content.subtitle)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                Text(content.duration)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.cardSurface, in: .capsule)
        }
    }

    private func sectionCard(_ section: CurriculumContentSection, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4, height: 20)
                Text(section.heading)
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text(section.body)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary.opacity(0.85))
                .lineSpacing(5)
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(accentColor.opacity(0.06), lineWidth: 1)
        )
    }

    private func takeawaysSection(_ content: CurriculumSessionContent) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Theme.gold)
                Text("Key Takeaways")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            ForEach(Array(content.keyTakeaways.enumerated()), id: \.offset) { index, takeaway in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(accentColor)
                        .frame(width: 22, height: 22)
                        .background(accentColor.opacity(0.12), in: Circle())

                    Text(takeaway)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary.opacity(0.85))
                        .lineSpacing(3)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.gold.opacity(0.06), Theme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.gold.opacity(0.1), lineWidth: 1)
        )
    }

    private func reflectionSection(_ content: CurriculumSessionContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.and.outline")
                    .foregroundStyle(accentColor)
                Text("Reflect")
                    .font(Theme.headingFont(.headline))
                    .foregroundStyle(Theme.textPrimary)
            }

            Text(content.reflectionPrompt)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)

            TextField("Your thoughts...", text: $reflectionText, axis: .vertical)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(3...6)
                .padding(14)
                .background(Theme.background, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.textSecondary.opacity(0.12), lineWidth: 1)
                )
        }
        .padding(20)
        .background(Theme.cardSurface, in: .rect(cornerRadius: 16))
    }

    private var completeButton: some View {
        Button {
            completeSession()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                Text("Complete Session \(sessionNumber)")
                    .font(.headline)
            }
            .foregroundStyle(Theme.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(accentColor, in: .rect(cornerRadius: 14))
        }
        .buttonStyle(PressableButtonStyle())
        .sensoryFeedback(.success, trigger: showCompletion)
        .accessibilityLabel("Complete session \(sessionNumber)")
    }

    private var completedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(accentColor)
            Text("Session Completed")
                .font(.headline)
                .foregroundStyle(accentColor)
            if let date = existingSession?.completedDate {
                Spacer()
                Text(date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(accentColor.opacity(0.08), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    private var completionSheet: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(accentColor)
            }

            Text("Session \(sessionNumber) Complete!")
                .font(Theme.headingFont(.title2))
                .foregroundStyle(Theme.textPrimary)

            Text("+150 XP earned")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(accentColor)

            Button {
                showCompletion = false
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(accentColor, in: .rect(cornerRadius: 12))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(24)
    }

    private func completeSession() {
        if let existing = existingSession {
            existing.isCompleted = true
            existing.completedDate = Date()
            existing.notes = reflectionText
        } else {
            let session = CurriculumSession(sessionNumber: sessionNumber, notes: reflectionText)
            session.isCompleted = true
            session.completedDate = Date()
            modelContext.insert(session)
        }

        if let profile {
            profile.xpPoints += XPAction.curriculumSession.xpValue
            profile.totalConsciousChoices += 1
        }

        awardSessionBadge()

        if sessionNumber == 8 && allSessionsCompleted {
            awardProgramGraduateBadge()
            showCompletion = true
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                showCompletion = false
                try? await Task.sleep(for: .seconds(0.3))
                showProgramCertificate = true
            }
        } else {
            showCompletion = true
        }
    }

    private func awardSessionBadge() {
        let badgeName = "Session \(sessionNumber) Complete"
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { $0.name == badgeName })
        guard let badge = try? modelContext.fetch(descriptor).first, !badge.isEarned else { return }
        badge.isEarned = true
        badge.dateEarned = Date()
    }

    private func awardProgramGraduateBadge() {
        let name = "Program Graduate"
        let descriptor = FetchDescriptor<Badge>(predicate: #Predicate { $0.name == name })
        guard let badge = try? modelContext.fetch(descriptor).first, !badge.isEarned else { return }
        badge.isEarned = true
        badge.dateEarned = Date()
    }
}

struct ProgramCertificateSheet: View {
    let userName: String
    let completionDate: Date
    let characterStage: CharacterStage

    @Environment(\.dismiss) private var dismiss

    private let purple = Color(red: 0.55, green: 0.3, blue: 0.85)

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(Theme.gold)

                    Text("Congratulations!")
                        .font(Theme.headingFont(.largeTitle))
                        .foregroundStyle(Theme.textPrimary)
                }

                VStack(spacing: 20) {
                    Text("CERTIFICATE OF COMPLETION")
                        .font(.caption.weight(.bold))
                        .tracking(3)
                        .foregroundStyle(Theme.gold)

                    Rectangle()
                        .fill(Theme.gold.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 40)

                    Text("This certifies that")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    Text(userName)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text("has successfully completed all 8 sessions of the")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("Splurj Program")
                        .font(Theme.headingFont(.title2))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.gold, Color(red: 1, green: 179/255, blue: 0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Rectangle()
                        .fill(Theme.gold.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 40)

                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Image(systemName: characterStage.bodyIcon)
                                .font(.title2)
                                .foregroundStyle(characterStage.primaryColor)
                            Text(characterStage.name)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundStyle(Theme.teal)
                            Text(completionDate, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.accentGreen)
                            Text("8/8 Sessions")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [Theme.gold.opacity(0.06), Theme.cardSurface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 20)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Theme.gold.opacity(0.2), lineWidth: 1.5)
                )

                Text("Based on the UCLA Gambling CBT manual and internet-delivered CBT research. You now have the knowledge, tools, and plan to navigate your journey with confidence.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal)

                ShareLink(
                    item: "I completed all 8 sessions of the Splurj Program! Building healthier money habits one day at a time.",
                    subject: Text("Splurj Program Complete"),
                    message: Text("I'm proud of this milestone!")
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share My Achievement")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Theme.gold, Color(red: 1, green: 179/255, blue: 0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: .rect(cornerRadius: 14)
                    )
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .padding(24)
            .padding(.top, 8)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
