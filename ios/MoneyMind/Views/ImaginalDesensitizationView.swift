import SwiftUI
import SwiftData

struct ImaginalDesensitizationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var characterVM = CharacterViewModel()

    @State private var currentStep: Int = 0
    @State private var initialRating: Double = 5
    @State private var finalRating: Double = 5
    @State private var stepTimer: Int = 0
    @State private var timerTask: Task<Void, Never>?
    @State private var isCompleted = false

    private var profile: UserProfile? { profiles.first }

    private let steps: [GuidedStep] = [
        GuidedStep(title: "Rate Your Urge", instruction: "On a scale of 0-10, how strong is your urge right now?", duration: 0, icon: "gauge.with.dots.needle.33percent"),
        GuidedStep(title: "Close Your Eyes", instruction: "Take a deep breath. Imagine the scene that triggers your urge. Picture it clearly — the place, the sounds, the feelings.", duration: 120, icon: "eye.slash.fill"),
        GuidedStep(title: "Notice Your Body", instruction: "Where do you feel the urge in your body? Your chest? Stomach? Hands? Just observe without judging.", duration: 90, icon: "figure.stand"),
        GuidedStep(title: "Apply Coping", instruction: "Now breathe slowly. 4 counts in, 7 counts hold, 8 counts out. Ground yourself in this moment. You are safe.", duration: 120, icon: "wind"),
        GuidedStep(title: "Re-Rate Your Urge", instruction: "How strong is the urge now? Notice any change, even small.", duration: 0, icon: "gauge.with.dots.needle.33percent"),
        GuidedStep(title: "Reflect", instruction: "", duration: 0, icon: "sparkles")
    ]

    private var progress: Double {
        Double(currentStep) / Double(steps.count - 1)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                progressBar
                stepContent
            }
        }
        .onDisappear { timerTask?.cancel() }
    }

    private var header: some View {
        HStack {
            Button("Close") {
                timerTask?.cancel()
                dismiss()
            }
            .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text("Imaginal Desensitization")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text("Step \(currentStep + 1)/\(steps.count)")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.cardSurface)
                    .frame(height: 4)

                Capsule()
                    .fill(Color(red: 0.6, green: 0.3, blue: 0.9))
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private var stepContent: some View {
        let step = steps[currentStep]

        ScrollView {
            VStack(spacing: 28) {
                Spacer().frame(height: 24)

                Image(systemName: step.icon)
                    .font(Typography.displayLarge)
                    .foregroundStyle(Color(red: 0.6, green: 0.3, blue: 0.9))
                    .frame(width: 80, height: 80)
                    .background(Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.12), in: .circle)

                Text(step.title)
                    .font(Typography.displaySmall)
                    .foregroundStyle(Theme.textPrimary)

                if currentStep == 0 {
                    initialRatingView(step: step)
                } else if currentStep == 4 {
                    finalRatingView(step: step)
                } else if currentStep == 5 {
                    reflectionView
                } else {
                    timedStepView(step: step)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 80)
        }
    }

    private func initialRatingView(step: GuidedStep) -> some View {
        VStack(spacing: 24) {
            Text(step.instruction)
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Text("\(Int(initialRating))")
                .font(Typography.displayLarge)
                .foregroundStyle(Color(red: 0.6, green: 0.3, blue: 0.9))
                .contentTransition(.numericText())
                .animation(.default, value: Int(initialRating))

            Slider(value: $initialRating, in: 0...10, step: 1)
                .tint(Color(red: 0.6, green: 0.3, blue: 0.9))
                .sensoryFeedback(.selection, trigger: Int(initialRating))

            HStack {
                Text("No urge").font(Typography.labelSmall).foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Extreme").font(Typography.labelSmall).foregroundStyle(Theme.textSecondary)
            }

            Button {
                withAnimation(.spring(response: 0.5)) { currentStep = 1 }
                startStepTimer(duration: steps[1].duration)
            } label: {
                Text("Begin Exercise")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.8)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: .rect(cornerRadius: 12)
                    )
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
        }
    }

    private func finalRatingView(step: GuidedStep) -> some View {
        VStack(spacing: 24) {
            Text(step.instruction)
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            Text("\(Int(finalRating))")
                .font(Typography.displayLarge)
                .foregroundStyle(Color(red: 0.6, green: 0.3, blue: 0.9))
                .contentTransition(.numericText())
                .animation(.default, value: Int(finalRating))

            Slider(value: $finalRating, in: 0...10, step: 1)
                .tint(Color(red: 0.6, green: 0.3, blue: 0.9))
                .sensoryFeedback(.selection, trigger: Int(finalRating))

            HStack {
                Text("No urge").font(Typography.labelSmall).foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("Extreme").font(Typography.labelSmall).foregroundStyle(Theme.textSecondary)
            }

            Button {
                withAnimation(.spring(response: 0.5)) { currentStep = 5 }
            } label: {
                Text("See Results")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.8)],
                            startPoint: .leading, endPoint: .trailing
                        ),
                        in: .rect(cornerRadius: 12)
                    )
            }
            .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
        }
    }

    private var reflectionView: some View {
        VStack(spacing: 24) {
            let drop = Int(initialRating) - Int(finalRating)

            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("Before")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(Int(initialRating))")
                        .font(Typography.displayMedium)
                        .foregroundStyle(Theme.emergency)
                }

                Image(systemName: "arrow.right")
                    .font(Typography.displaySmall)
                    .foregroundStyle(Theme.textSecondary)

                VStack(spacing: 4) {
                    Text("After")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                    Text("\(Int(finalRating))")
                        .font(Typography.displayMedium)
                        .foregroundStyle(Theme.accentGreen)
                }
            }

            if drop > 0 {
                Text("Your urge dropped by \(drop) points")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.accentGreen)
            } else if drop == 0 {
                Text("Your urge held steady — that's okay")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.gold)
            } else {
                Text("It takes practice. Each session builds resilience.")
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.teal)
            }

            Text("Based on Grant 2009: 79.5% of participants showed significant improvement with this technique over time.")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            if !isCompleted {
                Button {
                    completeSession()
                } label: {
                    Text("Complete Session")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentGradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            }

            if isCompleted {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(Typography.displayMedium)
                        .foregroundStyle(Theme.accentGreen)

                    Text("+100 XP")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.gold)
                }
                .transition(.scale.combined(with: .opacity))
                .sensoryFeedback(.success, trigger: isCompleted)
            }
        }
    }

    private func timedStepView(step: GuidedStep) -> some View {
        VStack(spacing: 24) {
            Text(step.instruction)
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)

            if step.duration > 0 {
                ZStack {
                    Circle()
                        .stroke(Theme.cardSurface, lineWidth: 8)
                        .frame(width: 120, height: 120)

                    let elapsed = Double(stepTimer)
                    let total = Double(step.duration)
                    Circle()
                        .trim(from: 0, to: min(1.0, elapsed / total))
                        .stroke(Color(red: 0.6, green: 0.3, blue: 0.9), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: stepTimer)

                    Text(formatTime(max(0, step.duration - stepTimer)))
                        .font(Typography.displaySmall)
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())
                        .animation(.default, value: stepTimer)
                }

                if stepTimer >= step.duration {
                    Button {
                        advanceStep()
                    } label: {
                        Text("Continue")
                            .font(Typography.headingMedium)
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.2, blue: 0.8)],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                in: .rect(cornerRadius: 12)
                            )
                    }
                    .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .sensoryFeedback(.impact(weight: .light), trigger: stepTimer)
                }
            }
        }
    }

    private func startStepTimer(duration: Int) {
        stepTimer = 0
        timerTask?.cancel()
        guard duration > 0 else { return }
        timerTask = Task {
            while !Task.isCancelled && stepTimer < duration {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                stepTimer += 1
            }
        }
    }

    private func advanceStep() {
        let next = currentStep + 1
        guard next < steps.count else { return }
        withAnimation(.spring(response: 0.5)) { currentStep = next }
        startStepTimer(duration: steps[next].duration)
    }

    private func completeSession() {
        let session = ImaginalSession(initialUrgeRating: Int(initialRating), finalUrgeRating: Int(finalRating))
        modelContext.insert(session)

        if let profile {
            characterVM.syncFromProfile(profile)
            characterVM.awardXP(.cbtExercise, to: profile)
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isCompleted = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            dismiss()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct GuidedStep {
    let title: String
    let instruction: String
    let duration: Int
    let icon: String
}
