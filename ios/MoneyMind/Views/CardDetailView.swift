import SwiftUI

struct CardDetailView: View {
    let card: CardDefinition
    let collectedInfo: CollectedCard?
    @Environment(\.dismiss) private var dismiss
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                CardArtView(card: card)
                    .frame(width: 260, height: 370)
                    .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotationY = value.translation.width / 10
                                rotationX = -value.translation.height / 10
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    rotationX = 0
                                    rotationY = 0
                                }
                            }
                    )
                    .shadow(color: card.rarity.color.opacity(0.3), radius: 24)

                VStack(spacing: 8) {
                    Text(card.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)

                    HStack(spacing: 6) {
                        Text(card.rarity.label)
                        Text(card.rarity.rawValue)
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(card.rarity.color)

                    Text(card.set.rawValue)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(card.set.accentColor.opacity(0.7))

                    Text("\"\(card.tip)\"")
                        .font(.system(size: 15, weight: .medium))
                        .italic()
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 4)

                    if let info = collectedInfo {
                        HStack(spacing: 16) {
                            if info.duplicateCount > 0 {
                                Label("x\(info.duplicateCount + 1)", systemImage: "square.stack.fill")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundStyle(Theme.textMuted)
                            }
                            Label(info.obtainedAt.formatted(.dateTime.month(.abbreviated).day()), systemImage: "calendar")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Theme.textMuted)
                        }
                        .padding(.top, 8)
                    }
                }

                Spacer()

                Button("Close") { dismiss() }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.accent)
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            if let info = collectedInfo, info.isNew {
                info.isNew = false
            }
        }
    }
}
