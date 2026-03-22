import SwiftUI

struct MMAmountDisplay: View {
    let amount: Double
    var prefix: String = "$"
    var font: Font = Theme.amountXL
    var color: Color = Theme.textPrimary

    @State private var displayedAmount: Double = 0
    @State private var hasAppeared = false

    var body: some View {
        Text("\(prefix)\(displayedAmount, specifier: displayedAmount >= 1000 ? "%.0f" : "%.2f")")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText(value: displayedAmount))
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                withAnimation(.easeInOut(duration: 0.8)) {
                    displayedAmount = amount
                }
            }
            .onChange(of: amount) { _, newValue in
                withAnimation(.easeInOut(duration: 0.8)) {
                    displayedAmount = newValue
                }
            }
    }
}
