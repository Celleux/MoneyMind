import SwiftUI
import SwiftData

struct BudgetTemplateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var budgets: [BudgetCategory]
    @Query private var quizResults: [QuizResult]
    @State private var vm = BudgetTemplateViewModel()
    @State private var appeared = false

    private var personality: MoneyPersonality {
        quizResults.first?.personality ?? .builder
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                switch vm.currentStep {
                case .selectTemplate:
                    templateSelectionContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .enterIncome:
                    incomeEntryContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .reviewCategories:
                    categoryReviewContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .confirm:
                    confirmContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if vm.currentStep == .selectTemplate {
                            dismiss()
                        } else {
                            vm.goBack()
                        }
                    } label: {
                        if vm.currentStep == .selectTemplate {
                            Text("Cancel")
                                .foregroundStyle(Theme.textSecondary)
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(Typography.headingSmall)
                                Text("Back")
                            }
                            .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
            .sensoryFeedback(.success, trigger: vm.hapticTrigger)
        }
    }

    // MARK: - Template Selection

    private var templateSelectionContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Budget Templates")
                        .font(Typography.displayMedium)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Choose a method that fits your style")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 8)
                .staggerIn(appeared: appeared, delay: 0.0)

                ForEach(Array(BudgetTemplateType.allCases.enumerated()), id: \.element.id) { index, template in
                    templateCard(template)
                        .staggerIn(appeared: appeared, delay: 0.05 + Double(index) * 0.08)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.easeOut(duration: 0.1)) {
                appeared = true
            }
        }
    }

    private func templateCard(_ template: BudgetTemplateType) -> some View {
        Button {
            vm.selectTemplate(template)
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [template.accentColor.opacity(0.15), template.accentColor.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    templatePreview(template)
                }
                .frame(height: 140)
                .clipShape(.rect(cornerRadii: .init(topLeading: 20, topTrailing: 20)))

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(template.rawValue)
                            .font(Typography.displaySmall)
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        if template.recommendedPersonality == personality {
                            recommendedPill(personality)
                        }
                    }

                    Text(template.subtitle)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(template.accentColor)

                    Text(template.description)
                        .font(Typography.bodySmall)
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Text("Get Started")
                                .font(Typography.headingSmall)
                            Image(systemName: "arrow.right")
                                .font(Typography.labelMedium)
                        }
                        .foregroundStyle(template.accentColor)
                    }
                }
                .padding(20)
            }
            .splurjCard(.elevated)
        }
        .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
    }

    @ViewBuilder
    private func templatePreview(_ template: BudgetTemplateType) -> some View {
        switch template {
        case .fiftyThirtyTwenty:
            threeRingPreview(template.accentColor)
        case .zeroBased:
            zeroBasedPreview(template.accentColor)
        case .envelope:
            envelopePreview(template.accentColor)
        case .payYourselfFirst:
            payYourselfPreview(template.accentColor)
        case .custom:
            customPreview(template.accentColor)
        }
    }

    private func threeRingPreview(_ color: Color) -> some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(["50%", "30%", "20%"], [0.5, 0.3, 0.2]).enumerated()), id: \.offset) { _, pair in
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .stroke(color.opacity(0.15), lineWidth: 5)
                            .frame(width: 46, height: 46)
                        Circle()
                            .trim(from: 0, to: pair.1)
                            .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                            .frame(width: 46, height: 46)
                            .rotationEffect(.degrees(-90))
                        Text(pair.0)
                            .font(Typography.labelSmall)
                            .foregroundStyle(color)
                    }
                }
            }
        }
    }

    private func zeroBasedPreview(_ color: Color) -> some View {
        VStack(spacing: 8) {
            Text("$0")
                .font(Typography.displayMedium)
                .foregroundStyle(color)
            Text("Unassigned")
                .font(Typography.bodySmall)
                .foregroundStyle(color.opacity(0.7))

            HStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color.opacity(Double(7 - i) / 7.0))
                        .frame(width: 20, height: 6)
                }
            }
        }
    }

    private func envelopePreview(_ color: Color) -> some View {
        HStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { i in
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.1))
                            .frame(width: 44, height: 32)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(Double(4 - i) / 5.0))
                            .frame(width: 36, height: max(4, 24 - Double(i * 6)))
                            .frame(width: 36, height: 24, alignment: .bottom)
                        Image(systemName: "envelope.fill")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(color.opacity(0.3))
                    }
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color.opacity(0.3))
                        .frame(width: 30, height: 3)
                }
            }
        }
    }

    private func payYourselfPreview(_ color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                    .frame(width: 72, height: 72)
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "arrow.up.circle.fill")
                    .font(Typography.displaySmall)
                    .foregroundStyle(color)
            }
            Text("Save First")
                .font(Typography.labelSmall)
                .foregroundStyle(color.opacity(0.7))
        }
    }

    private func customPreview(_ color: Color) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.08))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "plus")
                                .font(Typography.bodyLarge)
                                .foregroundStyle(color.opacity(0.4))
                        )
                }
            }
            Text("Your Categories")
                .font(Typography.labelSmall)
                .foregroundStyle(color.opacity(0.7))
        }
    }

    private func recommendedPill(_ personality: MoneyPersonality) -> some View {
        Text("For \(personality.rawValue.replacingOccurrences(of: "The ", with: ""))s")
            .font(Typography.labelSmall)
            .foregroundStyle(personality.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(personality.color.opacity(0.12), in: .capsule)
    }

    // MARK: - Income Entry

    private var incomeEntryContent: some View {
        let template = vm.selectedTemplate ?? .fiftyThirtyTwenty
        return VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 6) {
                        Image(systemName: template.icon)
                            .font(Typography.displayLarge)
                            .foregroundStyle(template.accentColor)
                            .padding(.bottom, 4)
                        Text(template.rawValue)
                            .font(Typography.displaySmall)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Enter your monthly income to get started")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 32)

                    VStack(spacing: 12) {
                        Text("Monthly Income")
                            .font(Typography.bodySmall)
                            .foregroundStyle(Theme.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("$")
                                .font(Typography.displayMedium)
                                .foregroundStyle(template.accentColor.opacity(0.6))
                            TextField("0", text: $vm.monthlyIncome)
                                .font(Typography.displayLarge)
                                .keyboardType(.decimalPad)
                                .foregroundStyle(Theme.textPrimary)
                                .tint(template.accentColor)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .splurjCard(.elevated)
                    }
                    .padding(.horizontal)

                    if template == .payYourselfFirst {
                        savingsPercentageSlider(template)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 12) {
                Button {
                    vm.proceedToReview()
                } label: {
                    Text("Generate Budget")
                        .font(Typography.headingMedium)
                        .foregroundStyle(vm.canProceedFromIncome ? Theme.background : Theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            vm.canProceedFromIncome ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.elevated),
                            in: .capsule
                        )
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
                .disabled(!vm.canProceedFromIncome)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func savingsPercentageSlider(_ template: BudgetTemplateType) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text("Savings Target")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(Int(vm.savingsPercentage))%")
                    .font(Typography.displaySmall)
                    .foregroundStyle(template.accentColor)
                    .contentTransition(.numericText())
            }

            Slider(value: $vm.savingsPercentage, in: 5...50, step: 1)
                .tint(template.accentColor)

            if vm.canProceedFromIncome {
                let savingsAmount = (vm.incomeValue * vm.savingsPercentage / 100).rounded()
                Text("You'll save $\(Int(savingsAmount))/month, budget the remaining $\(Int(vm.incomeValue - savingsAmount))")
                    .font(Typography.bodySmall)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(20)
        .splurjCard(.elevated)
    }

    // MARK: - Category Review

    private var categoryReviewContent: some View {
        let template = vm.selectedTemplate ?? .fiftyThirtyTwenty
        return VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
                    templateSpecificHeader(template)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Categories")
                                .font(Typography.headingMedium)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text("\(vm.allocations.count) items")
                                .font(Typography.bodySmall)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        ForEach(Array(vm.allocations.enumerated()), id: \.element.id) { index, alloc in
                            allocationRow(index: index, alloc: alloc, template: template)
                        }
                    }
                    .padding(20)
                    .splurjCard(.elevated)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 12) {
                Button {
                    vm.proceedToConfirm()
                } label: {
                    Text("Review Summary")
                        .font(Typography.headingMedium)
                        .foregroundStyle(Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.accentGradient, in: .capsule)
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private func templateSpecificHeader(_ template: BudgetTemplateType) -> some View {
        switch template {
        case .fiftyThirtyTwenty:
            fiftyThirtyTwentyHeader
        case .zeroBased:
            zeroBasedHeader
        case .envelope:
            envelopeHeader
        case .payYourselfFirst:
            payYourselfFirstHeader
        case .custom:
            customHeader
        }
    }

    private var fiftyThirtyTwentyHeader: some View {
        let data = vm.needsRingData()
        return VStack(spacing: 16) {
            Text("50 / 30 / 20 Split")
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 24) {
                ringColumn(label: "Needs", value: data.needs, target: 0.5, color: Color(hex: 0x6C5CE7))
                ringColumn(label: "Wants", value: data.wants, target: 0.3, color: Color(hex: 0x00D2FF))
                ringColumn(label: "Savings", value: data.savings, target: 0.2, color: Color(hex: 0x00E676))
            }
        }
        .padding(20)
        .splurjCard(.elevated)
    }

    private func ringColumn(label: String, value: Double, target: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: min(value, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(value * 100))%")
                    .font(Typography.labelMedium)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
            Text("\(Int(target * 100))% target")
                .font(Typography.labelSmall)
                .foregroundStyle(Theme.textMuted)
        }
    }

    private var zeroBasedHeader: some View {
        VStack(spacing: 12) {
            Text("Unassigned")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
            Text("$\(Int(vm.unassigned))")
                .font(Typography.displayLarge)
                .foregroundStyle(vm.isFullyAssigned ? Theme.accentGreen : Color(hex: 0x00D2FF))
                .contentTransition(.numericText(value: vm.unassigned))
                .animation(.spring(response: 0.3), value: vm.unassigned)

            if vm.isFullyAssigned {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.accentGreen)
                    Text("Every dollar assigned!")
                        .font(Typography.headingSmall)
                        .foregroundStyle(Theme.accentGreen)
                }
            }

            GeometryReader { geo in
                let allocated = vm.incomeValue > 0 ? min(vm.totalAllocated / vm.incomeValue, 1.0) : 0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.border)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x00D2FF), Color(hex: 0x00E676)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * allocated, height: 8)
                        .animation(.spring(response: 0.4), value: allocated)
                }
            }
            .frame(height: 8)
        }
        .padding(20)
        .splurjCard(.elevated)
    }

    private var envelopeHeader: some View {
        VStack(spacing: 14) {
            Text("Digital Envelopes")
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.textPrimary)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(vm.allocations) { alloc in
                    let fillRatio = vm.incomeValue > 0 ? alloc.amount / vm.incomeValue : 0
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: UInt(alloc.colorHex, radix: 16) ?? 0xFF9100).opacity(0.08))
                                .frame(height: 36)
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: UInt(alloc.colorHex, radix: 16) ?? 0xFF9100).opacity(0.3))
                                .frame(height: 36 * min(fillRatio * 3, 1))
                                .frame(height: 36, alignment: .bottom)
                            Image(systemName: "envelope.fill")
                                .font(Typography.bodySmall)
                                .foregroundStyle(Color(hex: UInt(alloc.colorHex, radix: 16) ?? 0xFF9100).opacity(0.5))
                        }
                        Text(alloc.name)
                            .font(Typography.labelSmall)
                            .foregroundStyle(Theme.textMuted)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(20)
        .splurjCard(.elevated)
    }

    private var payYourselfFirstHeader: some View {
        let savingsAlloc = vm.allocations.first { $0.name == "Savings" }
        let savingsAmount = savingsAlloc?.amount ?? 0
        let savingsRatio = vm.incomeValue > 0 ? savingsAmount / vm.incomeValue : 0

        return VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Theme.accentGreen.opacity(0.15), lineWidth: 10)
                    .frame(width: 100, height: 100)
                Circle()
                    .trim(from: 0, to: min(savingsRatio, 1.0))
                    .stroke(Theme.accentGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 2) {
                    Text("$\(Int(savingsAmount))")
                        .font(Typography.displaySmall)
                        .foregroundStyle(Theme.accentGreen)
                    Text("Saved")
                        .font(Typography.labelSmall)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Text("$\(Int(vm.incomeValue - savingsAmount)) remaining to budget")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(20)
        .splurjCard(.elevated)
    }

    private var customHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "slider.horizontal.3")
                .font(Typography.displayMedium)
                .foregroundStyle(Color(hex: 0xA55EEA))
            Text("Custom Budget")
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.textPrimary)
            Text("Adjust amounts to fit your needs")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .splurjCard(.elevated)
    }

    private func allocationRow(index: Int, alloc: BudgetAllocation, template: BudgetTemplateType) -> some View {
        let color = Color(hex: UInt(alloc.colorHex, radix: 16) ?? 0x6C5CE7)
        let progress = vm.incomeValue > 0 ? alloc.amount / vm.incomeValue : 0

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: alloc.icon)
                    .font(Typography.labelLarge)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(alloc.name)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Theme.textPrimary)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.border)
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color)
                            .frame(width: geo.size.width * min(progress, 1.0), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            HStack(spacing: 2) {
                Text("$")
                    .font(Typography.headingSmall)
                    .foregroundStyle(Theme.textSecondary)
                TextField("0", text: Binding(
                    get: { alloc.amount > 0 ? String(Int(alloc.amount)) : "" },
                    set: { newValue in
                        let val = Double(newValue) ?? 0
                        vm.updateAllocation(at: index, amount: val)
                    }
                ))
                .font(Typography.headingMedium)
                .keyboardType(.numberPad)
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Theme.elevated, in: .rect(cornerRadius: 10))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Confirm

    private var confirmContent: some View {
        let template = vm.selectedTemplate ?? .fiftyThirtyTwenty
        return VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(template.accentColor.opacity(0.1))
                                .frame(width: 72, height: 72)
                            Image(systemName: template.icon)
                                .font(Typography.displayMedium)
                                .foregroundStyle(template.accentColor)
                        }
                        Text(template.rawValue)
                            .font(Typography.displaySmall)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Monthly Income: $\(Int(vm.incomeValue))")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 16)

                    VStack(spacing: 2) {
                        ForEach(vm.allocations) { alloc in
                            confirmRow(alloc)
                        }
                    }
                    .padding(16)
                    .splurjCard(.elevated)

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Budgeted")
                                .font(Typography.bodySmall)
                                .foregroundStyle(Theme.textSecondary)
                            Text("$\(Int(vm.totalAllocated))")
                                .font(Typography.displayMedium)
                                .foregroundStyle(Theme.textPrimary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Unassigned")
                                .font(Typography.bodySmall)
                                .foregroundStyle(Theme.textSecondary)
                            Text("$\(Int(vm.unassigned))")
                                .font(Typography.displayMedium)
                                .foregroundStyle(vm.unassigned > 0 ? Theme.warning : Theme.accentGreen)
                        }
                    }
                    .padding(20)
                    .splurjCard(.elevated)

                    if !budgets.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Theme.warning)
                            Text("This will replace your existing \(budgets.count) budget categories.")
                                .font(Typography.bodySmall)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .padding(14)
                        .background(Theme.warning.opacity(0.08), in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Theme.warning.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 12) {
                Button {
                    vm.saveBudgets(modelContext: modelContext, existingBudgets: budgets)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Create Budget")
                    }
                    .font(Typography.headingMedium)
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.accentGradient, in: .capsule)
                }
                .buttonStyle(SplurjButtonStyle(variant: .primary, size: .large))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }

    private func confirmRow(_ alloc: BudgetAllocation) -> some View {
        let color = Color(hex: UInt(alloc.colorHex, radix: 16) ?? 0x6C5CE7)
        let pct = vm.incomeValue > 0 ? (alloc.amount / vm.incomeValue) * 100 : 0

        return HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(alloc.name)
                .font(Typography.bodyMedium)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text("\(Int(pct))%")
                .font(Typography.bodySmall)
                .foregroundStyle(Theme.textSecondary)

            Text("$\(Int(alloc.amount))")
                .font(Typography.headingMedium)
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 70, alignment: .trailing)
        }
        .padding(.vertical, 10)
    }
}
