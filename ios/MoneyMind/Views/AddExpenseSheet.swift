import SwiftUI
import SwiftData

struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var selectedCategory: TransactionCategory = .food
    @State private var hapticTrigger: Bool = false

    private let categories = TransactionCategory.expenseCategories

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    VStack(spacing: 6) {
                        Text("How much?")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("$")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textMuted)
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 200)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 90), spacing: 10)
                        ], spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: UInt(cat.color, radix: 16) ?? 0x64748B).opacity(selectedCategory == cat ? 0.25 : 0.1))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 18))
                                                .foregroundStyle(Color(hex: UInt(cat.color, radix: 16) ?? 0x64748B))
                                        }
                                        Text(cat.rawValue)
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(selectedCategory == cat ? Theme.textPrimary : Theme.textSecondary)
                                    }
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        selectedCategory == cat ? Theme.elevated : Theme.card,
                                        in: .rect(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                selectedCategory == cat
                                                    ? Color(hex: UInt(cat.color, radix: 16) ?? 0x64748B).opacity(0.4)
                                                    : Theme.border,
                                                lineWidth: 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)
                        TextField("What was this for?", text: $note)
                            .font(.body)
                            .padding(14)
                            .background(Theme.elevated, in: .rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Theme.border, lineWidth: 0.5)
                            )
                    }

                    Button {
                        saveExpense()
                    } label: {
                        Text("Add Expense")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.danger.opacity(amount.isEmpty ? 0.4 : 1), in: .rect(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(amount.isEmpty)
                    .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private func saveExpense() {
        guard let value = Double(amount), value > 0 else { return }
        let transaction = Transaction(
            amount: value,
            category: selectedCategory,
            note: note,
            type: .expense
        )
        modelContext.insert(transaction)
        hapticTrigger.toggle()
        dismiss()
    }
}
