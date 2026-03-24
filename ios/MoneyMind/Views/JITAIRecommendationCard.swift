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
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.teal)
                    Text("Smart Insights")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("JITAI")
                        .font(Typography.labelSmall)
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
                                    .font(Typography.headingMedium)
                                    .foregroundStyle(suggestion.color)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(suggestion.title)
                                    .font(Typography.headingSmall)
                                    .foregroundStyle(Theme.textPrimary)
                                Text(suggestion.message)
                                    .font(Typography.labelSmall)
                                    .foregroundStyle(Theme.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "chevron.right")
                                .font(Typography.labelSmall)
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
                    .buttonStyle(.plain)
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
            .splurjCard(.hero)
            .onAppear {
                withAnimation {
                    appeared = true
                }
            }
        }
    }
}
