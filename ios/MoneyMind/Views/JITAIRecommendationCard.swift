import SwiftUI

struct JITAIRecommendationCard: View {
    let suggestions: [JITAISuggestion]
    var onSelectTool: (JITAIToolType) -> Void = { _ in }

    @State private var appeared = false

    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.subheadline)
                        .foregroundStyle(Theme.teal)
                    Text("Smart Insights")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("JITAI")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.teal.opacity(0.7))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Theme.teal.opacity(0.1), in: .capsule)
                }

                ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, suggestion in
                    Button {
                        onSelectTool(suggestion.toolType)
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(suggestion.color.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: suggestion.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(suggestion.color)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(suggestion.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text(suggestion.message)
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(suggestion.color.opacity(0.5))
                        }
                        .padding(12)
                        .background(
                            LinearGradient(
                                colors: [suggestion.color.opacity(0.06), Theme.cardSurface.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: .rect(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(suggestion.color.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("\(suggestion.title): \(suggestion.message)")
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.08),
                        value: appeared
                    )
                }
            }
            .padding(16)
            .glassCard(cornerRadius: 20)
            .onAppear {
                withAnimation {
                    appeared = true
                }
            }
        }
    }
}
