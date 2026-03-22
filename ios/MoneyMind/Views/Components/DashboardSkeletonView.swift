import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.08),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width * 2)
                }
                .clipShape(.rect(cornerRadius: 8))
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct DashboardSkeletonView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                skeletonBlock(width: 120, height: 20)
                Spacer()
                skeletonCircle(size: 32)
            }
            .padding(.top, 16)

            VStack(spacing: 8) {
                skeletonBlock(width: 100, height: 14)
                skeletonBlock(width: 200, height: 48)
                skeletonBlock(width: 80, height: 16)
            }

            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    VStack(spacing: 8) {
                        skeletonCircle(size: 56)
                        skeletonBlock(width: 50, height: 12)
                    }
                }
            }

            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 8) {
                        skeletonCircle(size: 80)
                        skeletonBlock(width: 60, height: 12)
                        skeletonBlock(width: 50, height: 10)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .glassCard(cornerRadius: 20)

            skeletonBlock(width: .infinity, height: 180)

            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: 12) {
                    skeletonCircle(size: 10)
                    VStack(alignment: .leading, spacing: 4) {
                        skeletonBlock(width: 120, height: 14)
                        skeletonBlock(width: 80, height: 10)
                    }
                    Spacer()
                    skeletonBlock(width: 60, height: 16)
                }
                .padding(16)
                .glassCard()
            }
        }
    }

    private func skeletonBlock(width: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Theme.elevated)
            .frame(maxWidth: width == .infinity ? .infinity : width, maxHeight: height)
            .frame(height: height)
            .shimmer()
    }

    private func skeletonCircle(size: CGFloat) -> some View {
        Circle()
            .fill(Theme.elevated)
            .frame(width: size, height: size)
            .shimmer()
    }
}
