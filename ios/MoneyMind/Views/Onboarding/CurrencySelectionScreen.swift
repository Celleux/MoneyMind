import SwiftUI

struct CurrencySelectionScreen: View {
    @Binding var selectedCurrencyCode: String
    @Binding var selectedCurrencySymbol: String
    let onNext: () -> Void

    @State private var searchText: String = ""
    @State private var appeared = false

    private var popularCurrencies: [CurrencyInfo] {
        CurrencyInfo.popular
    }

    private var filteredCurrencies: [CurrencyInfo] {
        let nonPopularCodes = Set(CurrencyInfo.popular.map(\.code))
        let remaining = CurrencyInfo.all.filter { !nonPopularCodes.contains($0.code) }

        if searchText.isEmpty {
            return remaining
        }

        let query = searchText.lowercased()
        return CurrencyInfo.all.filter {
            $0.code.lowercased().contains(query) ||
            $0.name.lowercased().contains(query) ||
            $0.flag.contains(query)
        }
    }

    private var showPopularSection: Bool {
        searchText.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Choose Your Currency")
                    .font(Theme.headingFont(.title))
                    .foregroundStyle(Theme.textPrimary)

                Text("All amounts will display in your selected currency")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.top, 40)
            .padding(.bottom, 16)
            .opacity(appeared ? 1 : 0)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textMuted)
                TextField("Search currencies", text: $searchText)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(Theme.textPrimary)
                    .tint(Theme.accent)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textMuted)
                    }
                }
            }
            .padding(12)
            .background(Theme.elevated, in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.border, lineWidth: 0.5)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                    if showPopularSection {
                        Section {
                            ForEach(popularCurrencies) { currency in
                                currencyRow(currency)
                            }
                        } header: {
                            sectionHeader("Popular")
                        }

                        Section {
                            ForEach(filteredCurrencies) { currency in
                                currencyRow(currency)
                            }
                        } header: {
                            sectionHeader("All Currencies")
                        }
                    } else {
                        ForEach(filteredCurrencies) { currency in
                            currencyRow(currency)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(Theme.accentGradient, in: .rect(cornerRadius: 14))
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5)) {
                appeared = true
            }
        }
    }

    private func currencyRow(_ currency: CurrencyInfo) -> some View {
        let isSelected = selectedCurrencyCode == currency.code

        return Button {
            withAnimation(.spring(response: 0.25)) {
                selectedCurrencyCode = currency.code
                selectedCurrencySymbol = currency.symbol
            }
        } label: {
            HStack(spacing: 14) {
                Text(currency.flag)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.code)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text(currency.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                isSelected ? Theme.accent.opacity(0.08) : Color.clear,
                in: .rect(cornerRadius: 10)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textMuted)
                .tracking(1.5)
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Theme.background)
    }
}
