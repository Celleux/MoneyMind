import SwiftUI

struct HRVCardView: View {
    let hrvData: [HRVDataPoint]
    let trend: HRVTrend
    let todayHRV: Double
    let weekAvgHRV: Double
    let isStressDetected: Bool
    var onSurfUrge: () -> Void = {}

    @State private var appeared = false
    @State private var stressPulse = false

    var body: some View {
        VStack(spacing: 16) {
            headerRow
            sparklineChart
            statsRow

            if isStressDetected {
                stressAlert
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Theme.teal.opacity(0.06), Theme.cardSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isStressDetected
                        ? LinearGradient(colors: [Color.orange.opacity(0.3), Theme.emergency.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Theme.teal.opacity(0.15), Theme.teal.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }

    private var headerRow: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .font(Typography.headingLarge)
                    .foregroundStyle(Theme.teal)
                Text("Heart Rate Variability")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textPrimary)
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: trend.icon)
                    .font(Typography.labelSmall)
                Text(trend.label)
                    .font(Typography.labelSmall)
            }
            .foregroundStyle(trend.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(trend.color.opacity(0.12), in: .capsule)
        }
    }

    private var sparklineChart: some View {
        Canvas { context, size in
            guard hrvData.count >= 2 else { return }

            let values = hrvData.map(\.value)
            let minVal = (values.min() ?? 0) - 5
            let maxVal = (values.max() ?? 100) + 5
            let range = maxVal - minVal
            guard range > 0 else { return }

            let stepX = size.width / CGFloat(values.count - 1)
            let points = values.enumerated().map { i, val in
                CGPoint(
                    x: CGFloat(i) * stepX,
                    y: size.height - ((CGFloat(val) - CGFloat(minVal)) / CGFloat(range)) * size.height
                )
            }

            var fillPath = Path()
            fillPath.move(to: CGPoint(x: points[0].x, y: size.height))
            fillPath.addLine(to: points[0])
            for i in 1..<points.count {
                let control1 = CGPoint(
                    x: points[i-1].x + stepX * 0.4,
                    y: points[i-1].y
                )
                let control2 = CGPoint(
                    x: points[i].x - stepX * 0.4,
                    y: points[i].y
                )
                fillPath.addCurve(to: points[i], control1: control1, control2: control2)
            }
            fillPath.addLine(to: CGPoint(x: points.last!.x, y: size.height))
            fillPath.closeSubpath()

            let gradient = Gradient(colors: [
                trend == .declining ? Color.orange.opacity(0.2) : Theme.teal.opacity(0.2),
                Color.clear
            ])
            context.fill(
                fillPath,
                with: .linearGradient(gradient, startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height))
            )

            var linePath = Path()
            linePath.move(to: points[0])
            for i in 1..<points.count {
                let control1 = CGPoint(
                    x: points[i-1].x + stepX * 0.4,
                    y: points[i-1].y
                )
                let control2 = CGPoint(
                    x: points[i].x - stepX * 0.4,
                    y: points[i].y
                )
                linePath.addCurve(to: points[i], control1: control1, control2: control2)
            }

            let lineColor = trend == .declining ? Color.orange : Theme.teal
            context.stroke(linePath, with: .color(lineColor), lineWidth: 2.5)

            if let lastPoint = points.last {
                let dotColor = trend == .declining ? Color.orange : Theme.accentGreen
                let outerCircle = Path(ellipseIn: CGRect(
                    x: lastPoint.x - 6,
                    y: lastPoint.y - 6,
                    width: 12,
                    height: 12
                ))
                context.fill(outerCircle, with: .color(dotColor.opacity(0.3)))

                let innerCircle = Path(ellipseIn: CGRect(
                    x: lastPoint.x - 4,
                    y: lastPoint.y - 4,
                    width: 8,
                    height: 8
                ))
                context.fill(innerCircle, with: .color(dotColor))
            }

            for (i, point) in points.enumerated() where i < points.count - 1 {
                let dot = Path(ellipseIn: CGRect(
                    x: point.x - 2.5,
                    y: point.y - 2.5,
                    width: 5,
                    height: 5
                ))
                context.fill(dot, with: .color(lineColor.opacity(0.5)))
            }
        }
        .frame(height: 80)
        .accessibilityLabel("HRV sparkline chart showing 7-day trend")
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            VStack(spacing: 3) {
                Text(String(format: "%.0f", todayHRV))
                    .font(Typography.headingLarge)
                    .foregroundStyle(Theme.textPrimary)
                Text("Today (ms)")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Theme.textSecondary.opacity(0.15))
                .frame(width: 1, height: 32)

            VStack(spacing: 3) {
                Text(String(format: "%.0f", weekAvgHRV))
                    .font(Typography.headingLarge)
                    .foregroundStyle(Theme.textPrimary)
                Text("7-Day Avg")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Theme.textSecondary.opacity(0.15))
                .frame(width: 1, height: 32)

            VStack(spacing: 3) {
                let diff = weekAvgHRV > 0 ? ((todayHRV - weekAvgHRV) / weekAvgHRV) * 100 : 0
                Text("\(diff >= 0 ? "+" : "")\(String(format: "%.0f", diff))%")
                    .font(Typography.headingLarge)
                    .foregroundStyle(diff >= 0 ? Theme.accentGreen : Color.orange)
                Text("Change")
                    .font(Typography.labelSmall)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var stressAlert: some View {
        Button(action: onSurfUrge) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .scaleEffect(stressPulse ? 1.15 : 1.0)
                        .opacity(stressPulse ? 0.5 : 1.0)

                    Image(systemName: "waveform.path.ecg")
                        .font(Typography.headingLarge)
                        .foregroundStyle(.orange)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Stress Detected")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Would you like to surf it?")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Text("Surf It")
                    .font(Typography.labelSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Theme.teal, Theme.accentGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: .capsule
                    )
            }
            .padding(12)
            .background(
                LinearGradient(
                    colors: [Color.orange.opacity(0.08), Theme.emergency.opacity(0.04)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: .rect(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.25), Theme.emergency.opacity(0.15)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.warning, trigger: isStressDetected)
        .accessibilityLabel("Stress detected. Tap to open urge surf tool.")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                stressPulse = true
            }
        }
    }
}
