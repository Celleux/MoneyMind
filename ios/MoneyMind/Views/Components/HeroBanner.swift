import SwiftUI
import PhosphorSwift

struct HeroBanner: View {
    let title: String
    let subtitle: String
    var accentColor: Color = Theme.accent
    var icon: Image? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.15), Theme.background],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            SplurjSwoosh()
                .fill(accentColor.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 24))

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(Typography.displaySmall)
                        .foregroundStyle(Theme.textPrimary)

                    Text(subtitle)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                if let icon {
                    icon
                        .font(.system(size: 48))
                        .foregroundStyle(accentColor.opacity(0.4))
                }
            }
            .padding(24)
        }
        .frame(height: 160)
    }
}
