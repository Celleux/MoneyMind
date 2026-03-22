import SwiftUI

struct ShareableQuestCard: View {
    let questTitle: String
    let action: String
    let amountSaved: String
    let category: QuestCategory
    let playerLevel: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                Text("SPLURJ")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(4)

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [category.color.opacity(0.3), category.color.opacity(0.05)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)

                    Circle()
                        .stroke(category.color.opacity(0.4), lineWidth: 2)
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

                VStack(spacing: 6) {
                    Text("QUEST COMPLETE")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.accent)
                        .tracking(3)

                    Text(questTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 24)
                }

                if !amountSaved.isEmpty {
                    VStack(spacing: 4) {
                        Text(amountSaved)
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.gold, Color(hex: 0xFBBF24)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Theme.gold.opacity(0.3), radius: 12)

                        Text("SAVED")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(Theme.textSecondary)
                            .tracking(2)
                    }
                }

                Text("This app just gave me a quest to \(action.lowercased()) and I saved \(amountSaved.isEmpty ? "money" : amountSaved)!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(3)

                HStack(spacing: 20) {
                    shareStatChip(icon: "star.fill", value: "Lvl \(playerLevel)", color: Theme.gold)
                    shareStatChip(icon: category.icon, value: category.rawValue, color: category.color)
                }
            }

            Spacer()

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(Theme.accent)
                    Text("splurj.app")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Text("Don't splurge. Splurj.")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.bottom, 40)
        }
        .frame(width: 390, height: 693)
        .background(
            ZStack {
                Theme.background

                RadialGradient(
                    colors: [category.color.opacity(0.12), .clear],
                    center: .center,
                    startRadius: 40,
                    endRadius: 300
                )

                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: [
                        .clear, category.color.opacity(0.06), .clear,
                        Theme.accent.opacity(0.04), .clear, category.color.opacity(0.04),
                        .clear, Theme.accent.opacity(0.06), .clear
                    ]
                )
            }
        )
        .clipShape(.rect(cornerRadius: 24))
    }

    private func shareStatChip(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(color.opacity(0.1))
        )
        .overlay(
            Capsule().stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }

    @MainActor
    func renderImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1080, height: 1920))
        let hostingController = UIHostingController(
            rootView: self
                .frame(width: 390, height: 693)
                .scaleEffect(1080.0 / 390.0, anchor: .topLeading)
                .frame(width: 1080, height: 1920)
        )
        hostingController.view.bounds = CGRect(origin: .zero, size: CGSize(width: 1080, height: 1920))
        hostingController.view.backgroundColor = .clear
        hostingController.view.layoutIfNeeded()

        return renderer.image { context in
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ShareQuestButton: View {
    let questTitle: String
    let action: String
    let amountSaved: String
    let category: QuestCategory
    let playerLevel: Int

    @State private var shareImage: UIImage?
    @State private var showShareSheet: Bool = false

    var body: some View {
        Button {
            let card = ShareableQuestCard(
                questTitle: questTitle,
                action: action,
                amountSaved: amountSaved,
                category: category,
                playerLevel: playerLevel
            )
            shareImage = card.renderImage()
            if shareImage != nil {
                showShareSheet = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .bold))
                Text("Share Your Win")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule().fill(Theme.accent.opacity(0.15))
            )
            .overlay(
                Capsule().stroke(Theme.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }
}
