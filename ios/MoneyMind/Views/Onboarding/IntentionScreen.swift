import SwiftUI
import SwiftData

struct IntentionScreen: View {
    let modelContext: ModelContext
    let onComplete: () -> Void

    @State private var selectedIntention: String = ""
    @State private var customIntention: String = ""
    @State private var name: String = ""
    @State private var appeared = false
    @FocusState private var nameFocused: Bool

    private let prefilledOptions = [
        "Take 3 deep breaths and wait 10 minutes",
        "Open Splurj and log the urge",
        "Call my accountability partner"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("One Last Thing")
                        .font(Theme.headingFont(.title))
                        .foregroundStyle(Theme.textPrimary)

                    Text("Set your intention for when urges hit")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 40)
                .opacity(appeared ? 1 : 0)

                VStack(alignment: .leading, spacing: 12) {
                    Text("What should we call you?")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)

                    TextField("Your name", text: $name)
                        .font(.body)
                        .padding(16)
                        .background(Theme.cardSurface, in: .rect(cornerRadius: 8))
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.accentGreen)
                        .focused($nameFocused)
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    Text("\"If I feel the urge to spend impulsively, I will...\"")
                        .font(.subheadline.italic())
                        .foregroundStyle(Theme.teal)

                    VStack(spacing: 10) {
                        ForEach(prefilledOptions, id: \.self) { option in
                            let isSelected = selectedIntention == option
                            Button {
                                selectedIntention = option
                                customIntention = ""
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isSelected ? Theme.accentGreen : Theme.textSecondary)

                                    Text(option)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textPrimary)
                                        .multilineTextAlignment(.leading)

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    isSelected ? Theme.accentGreen.opacity(0.1) : Theme.cardSurface,
                                    in: .rect(cornerRadius: 12)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isSelected ? Theme.accentGreen.opacity(0.4) : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                            .sensoryFeedback(.selection, trigger: isSelected)
                        }

                        TextField("Or write your own...", text: $customIntention)
                            .font(.subheadline)
                            .padding(14)
                            .background(Theme.cardSurface, in: .rect(cornerRadius: 12))
                            .foregroundStyle(Theme.textPrimary)
                            .tint(Theme.accentGreen)
                            .onChange(of: customIntention) { _, newValue in
                                if !newValue.isEmpty { selectedIntention = "" }
                            }
                    }
                }
                .padding(.horizontal, 24)

                Button {
                    saveAndComplete()
                } label: {
                    Text("Let's Begin")
                        .font(.headline)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            canContinue
                                ? AnyShapeStyle(Theme.accentGradient)
                                : AnyShapeStyle(Color.gray.opacity(0.3)),
                            in: .rect(cornerRadius: 12)
                        )
                }
                .buttonStyle(PressableButtonStyle())
                .disabled(!canContinue)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .sensoryFeedback(.success, trigger: canContinue)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }

    private var canContinue: Bool {
        !name.isEmpty && (!selectedIntention.isEmpty || !customIntention.isEmpty)
    }

    private func saveAndComplete() {
        let profile = UserProfile(name: name)
        modelContext.insert(profile)

        let intentionText = customIntention.isEmpty ? selectedIntention : customIntention
        let intention = ImplementationIntention(intention: intentionText)
        modelContext.insert(intention)

        onComplete()
    }
}
