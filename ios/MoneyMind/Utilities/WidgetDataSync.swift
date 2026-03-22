import SwiftUI
import SwiftData
import WidgetKit

struct WidgetDataSyncModifier: ViewModifier {
    @Query private var transactions: [Transaction]
    @Query private var budgets: [BudgetCategory]
    @Query private var challenges: [SavingsChallenge]
    @Query private var quizResults: [QuizResult]

    @Environment(\.scenePhase) private var scenePhase

    private let writer = WidgetDataWriter()

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    syncWidgetData()
                }
            }
            .onChange(of: transactions.count) { _, _ in
                syncWidgetData()
            }
            .onChange(of: budgets.count) { _, _ in
                syncWidgetData()
            }
            .onAppear {
                syncWidgetData()
            }
    }

    private func syncWidgetData() {
        writer.updateWidgetData(
            transactions: transactions,
            budgets: budgets,
            challenges: challenges,
            quizResult: quizResults.first
        )
    }
}

extension View {
    func syncWidgetData() -> some View {
        modifier(WidgetDataSyncModifier())
    }
}
