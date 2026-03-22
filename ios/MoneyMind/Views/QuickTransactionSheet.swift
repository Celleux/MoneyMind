import SwiftUI
import SwiftData

struct QuickTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \Transaction.date, order: .reverse) private var recentTransactions: [Transaction]
    @Query private var merchantMappings: [MerchantCategoryMapping]

    @State private var amountString: String = ""
    @State private var selectedCategory: TransactionCategory = .food
    @State private var transactionType: TransactionType = .expense
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedVibe: String = ""
    @State private var showDatePicker: Bool = false
    @State private var showDismissAlert: Bool = false
    @State private var saveHaptic: Bool = false
    @State private var keyHaptic: Bool = false
    @State private var vibeHaptic: Bool = false
    @State private var savedSuccessfully: Bool = false
    @State private var showLearnPrompt: Bool = false
    @State private var learnMerchantName: String = ""
    @State private var learnCategory: TransactionCategory = .other

    private let engine = CategoryMLEngine()

    private var hasData: Bool {
        !amountString.isEmpty || !note.isEmpty || selectedVibe != ""
    }

    private var displayAmount: String {
        if amountString.isEmpty { return "0" }
        return amountString
    }

    private var categories: [TransactionCategory] {
        transactionType == .expense
            ? TransactionCategory.expenseCategories
            : TransactionCategory.incomeCategories
    }

    private var recentCategories: [TransactionCategory] {
        var seen: [TransactionCategory] = []
        let filtered = recentTransactions.filter {
            $0.transactionType == transactionType
        }
        for t in filtered {
            let cat = t.transactionCategory
            if !seen.contains(cat) {
                seen.append(cat)
            }
            if seen.count == 3 { break }
        }
        return seen
    }

    private var smartSuggestions: [TransactionCategory] {
        guard transactionType == .expense else { return [] }
        let recentCats = recentTransactions
            .filter { $0.transactionType == .expense }
            .prefix(10)
            .map(\.transactionCategory)
        return engine.suggestCategories(
            note: note,
            amount: Double(amountString),
            date: selectedDate,
            recentCategories: Array(recentCats),
            userMappings: merchantMappings
        )
    }

    private var saveColor: Color {
        transactionType == .expense ? Theme.accent : Theme.accentGreen
    }

    private var dateLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(selectedDate) { return "Today" }
        if cal.isDateInYesterday(selectedDate) { return "Yesterday" }
        return selectedDate.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            typeToggle
            amountDisplay
            smartSuggestionRow
            categorySection
            dateAndNoteRow
            vibeCheckRow
            saveButton
            numpad
        }
        .background(Theme.background.ignoresSafeArea())
        .sensoryFeedback(.impact(weight: .light), trigger: keyHaptic)
        .sensoryFeedback(.impact(weight: .light), trigger: vibeHaptic)
        .sensoryFeedback(.success, trigger: saveHaptic)
        .alert("Discard transaction?", isPresented: $showDismissAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) {}
        }
        .alert("Learn this category?", isPresented: $showLearnPrompt) {
            Button("Always") {
                engine.learnMapping(merchantKeyword: learnMerchantName, category: learnCategory, context: modelContext)
                engine.applyCategoryRetroactively(merchantKeyword: learnMerchantName, newCategory: learnCategory, context: modelContext)
            }
            Button("Just this time", role: .cancel) {}
        } message: {
            Text("Always categorize \"\(learnMerchantName)\" as \(learnCategory.rawValue)?")
        }
        .interactiveDismissDisabled(hasData)
        .onChange(of: note) { _, newValue in
            if transactionType == .expense, !newValue.isEmpty {
                if let matched = engine.matchMerchant(note: newValue, userMappings: merchantMappings) {
                    withAnimation(Theme.spring) {
                        selectedCategory = matched
                    }
                }
            }
        }
    }

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Theme.border)
            .frame(width: 36, height: 4)
            .padding(.top, 10)
            .padding(.bottom, 6)
    }

    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach([TransactionType.expense, .income], id: \.self) { type in
                Button {
                    withAnimation(Theme.spring) {
                        transactionType = type
                        selectedCategory = type == .expense ? .food : .income
                    }
                } label: {
                    Text(type == .expense ? "Expense" : "Income")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(transactionType == type ? .white : Theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            transactionType == type
                                ? (type == .expense ? Theme.accent : Theme.accentGreen)
                                : Color.clear,
                            in: .rect(cornerRadius: 10)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Theme.elevated, in: .rect(cornerRadius: 12))
        .padding(.horizontal, 80)
        .padding(.bottom, 8)
    }

    private var amountDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(CurrencyHelper.symbol(for: profiles.first?.defaultCurrency ?? "USD"))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textMuted)

            Text(displayAmount)
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.2, dampingFraction: 0.8), value: amountString)

            BlinkingCursor()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private var smartSuggestionRow: some View {
        Group {
            let suggestions = smartSuggestions
            if !suggestions.isEmpty && transactionType == .expense {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.accent)

                        ForEach(suggestions, id: \.self) { cat in
                            Button {
                                withAnimation(Theme.spring) {
                                    selectedCategory = cat
                                }
                                keyHaptic.toggle()
                            } label: {
                                HStack(spacing: 4) {
                                    Text(cat.emoji)
                                        .font(.system(size: 12))
                                    Text(cat.rawValue)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(selectedCategory == cat ? .white : Theme.accent)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    selectedCategory == cat ? Theme.accent.opacity(0.7) : Theme.accent.opacity(0.12),
                                    in: .capsule
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .frame(height: 32)
        .animation(Theme.spring, value: smartSuggestions)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !recentCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Text("Recent")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.textMuted)
                            .padding(.leading, 4)

                        ForEach(recentCategories, id: \.self) { cat in
                            categoryPill(cat)
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { cat in
                        categoryPill(cat)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
        .padding(.vertical, 6)
    }

    private func categoryPill(_ cat: TransactionCategory) -> some View {
        let isSelected = selectedCategory == cat
        let catColor = Color(hex: UInt(cat.color, radix: 16) ?? 0x64748B)
        return Button {
            withAnimation(Theme.spring) {
                selectedCategory = cat
            }
            keyHaptic.toggle()
        } label: {
            HStack(spacing: 4) {
                Text(cat.emoji)
                    .font(.system(size: 13))
                Text(cat.rawValue)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : Theme.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                isSelected ? catColor.opacity(0.85) : Theme.card,
                in: .capsule
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? catColor : Theme.border, lineWidth: 0.5)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(Theme.spring, value: isSelected)
        }
        .buttonStyle(.plain)
    }

    private var dateAndNoteRow: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(Theme.spring) {
                    selectedDate = Date()
                }
            } label: {
                Text(dateLabel)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Calendar.current.isDateInToday(selectedDate) ? Theme.secondary : Theme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.card, in: .capsule)
                    .overlay(Capsule().strokeBorder(Theme.border, lineWidth: 0.5))
            }
            .buttonStyle(.plain)

            if !Calendar.current.isDateInYesterday(selectedDate) && !Calendar.current.isDateInToday(selectedDate) {
            } else if Calendar.current.isDateInToday(selectedDate) {
                Button {
                    withAnimation(Theme.spring) {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
                    }
                } label: {
                    Text("Yesterday")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Theme.elevated, in: .capsule)
                }
                .buttonStyle(.plain)
            }

            Button {
                showDatePicker.toggle()
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textMuted)
                    .padding(7)
                    .background(Theme.elevated, in: .circle)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showDatePicker) {
                DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Theme.accent)
                    .frame(width: 320, height: 340)
                    .padding()
                    .presentationCompactAdaptation(.popover)
            }

            Spacer()

            TextField("Merchant / note...", text: $note)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .tint(Theme.accent)
                .frame(maxWidth: 140)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Theme.elevated, in: .capsule)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private let vibes: [(String, String)] = [
        ("\u{1F911}", "Worth it"),
        ("\u{1F610}", "Meh"),
        ("\u{1F62C}", "Regret"),
        ("\u{2705}", "Necessary"),
        ("\u{1F4AA}", "Flex")
    ]

    private var vibeCheckRow: some View {
        VStack(spacing: 4) {
            Text("Vibe Check")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.textMuted)

            HStack(spacing: 0) {
                ForEach(vibes, id: \.0) { vibe in
                    let isSelected = selectedVibe == vibe.0
                    Button {
                        withAnimation(Theme.spring) {
                            selectedVibe = selectedVibe == vibe.0 ? "" : vibe.0
                        }
                        vibeHaptic.toggle()
                    } label: {
                        VStack(spacing: 3) {
                            Text(vibe.0)
                                .font(.system(size: 26))
                                .scaleEffect(isSelected ? 1.25 : 1.0)

                            Text(vibe.1)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(isSelected ? Theme.textPrimary : Theme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(
                            isSelected ? Theme.accent.opacity(0.12) : Color.clear,
                            in: .rect(cornerRadius: 10)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
    }

    private var saveButton: some View {
        Button {
            saveTransaction()
        } label: {
            Text("Save")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    saveColor.opacity(amountString.isEmpty ? 0.35 : 1),
                    in: .rect(cornerRadius: 14)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(amountString.isEmpty)
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 2)
    }

    private let numpadKeys: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "\u{232B}"]
    ]

    private var numpad: some View {
        VStack(spacing: 6) {
            ForEach(numpadKeys, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(row, id: \.self) { key in
                        NumpadKey(label: key) {
                            handleKey(key)
                            keyHaptic.toggle()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .padding(.top, 4)
    }

    private func handleKey(_ key: String) {
        switch key {
        case "\u{232B}":
            if !amountString.isEmpty {
                amountString.removeLast()
            }
        case ".":
            if !amountString.contains(".") {
                amountString += amountString.isEmpty ? "0." : "."
            }
        default:
            if let dotIndex = amountString.firstIndex(of: ".") {
                let decimals = amountString[amountString.index(after: dotIndex)...]
                if decimals.count >= 2 { return }
            }
            if amountString.count < 8 {
                if amountString == "0" && key != "." {
                    amountString = key
                } else {
                    amountString += key
                }
            }
        }
    }

    private func saveTransaction() {
        guard let value = Double(amountString), value > 0 else { return }

        let adjustedCategory: TransactionCategory
        if transactionType == .income && !TransactionCategory.incomeCategories.contains(selectedCategory) {
            adjustedCategory = .income
        } else if transactionType == .expense && !TransactionCategory.expenseCategories.contains(selectedCategory) {
            adjustedCategory = .food
        } else {
            adjustedCategory = selectedCategory
        }

        let transaction = Transaction(
            amount: value,
            category: adjustedCategory,
            note: note,
            type: transactionType,
            moodEmoji: selectedVibe
        )
        transaction.date = selectedDate
        modelContext.insert(transaction)

        if !selectedVibe.isEmpty, let vibeType = VibeType(fromEmoji: selectedVibe) {
            let entry = VibeCheckEntry(
                transactionID: "\(transaction.persistentModelID.hashValue)",
                emoji: vibeType.emoji,
                sentiment: vibeType.sentiment,
                amount: value,
                categoryName: adjustedCategory.rawValue
            )
            modelContext.insert(entry)
        }

        if transactionType == .expense {
        } else if let profile = profiles.first {
            profile.totalSaved += 0
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        if !trimmedNote.isEmpty && transactionType == .expense {
            let matchedFromEngine = engine.matchMerchant(note: trimmedNote, userMappings: merchantMappings)
            if matchedFromEngine == nil || matchedFromEngine != adjustedCategory {
                learnMerchantName = trimmedNote
                learnCategory = adjustedCategory
            }
        }

        savedSuccessfully = true
        saveHaptic.toggle()

        if selectedVibe.isEmpty {
            NotificationCenter.default.post(name: .transactionSaved, object: transaction)
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            dismiss()
        }

        if !learnMerchantName.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLearnPrompt = true
            }
        }
    }
}

struct NumpadKey: View {
    let label: String
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if label == "\u{232B}" {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text(label)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                isPressed ? Theme.elevated : Theme.card,
                in: .rect(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct BlinkingCursor: View {
    @State private var visible: Bool = true

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Theme.accent)
            .frame(width: 2, height: 36)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}
