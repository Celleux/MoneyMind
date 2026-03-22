# Smart Category Engine — On-Device ML Categorization


## Features

- **Expanded to 15 categories**: Food & Dining, Transport, Shopping, Bills & Utilities, Entertainment, Health & Fitness, Education, Personal Care, Home, Travel, Gifts, Subscriptions, Income, Savings, Other — each with a unique emoji and color
- **Keyword-based merchant matching**: 50+ built-in merchant→category mappings (e.g. "Starbucks"→Food, "Uber"→Transport, "Amazon"→Shopping, "Netflix"→Subscriptions)
- **User correction learning**: When a user changes a transaction's category, the app asks "Always categorize [merchant] as [category]?" and saves the preference
- **Retroactive re-categorization**: Accepting a correction updates all past transactions from the same merchant
- **Smart suggestions on entry**: When adding a transaction, the top 3 category suggestions appear based on time of day, day of week, amount range, and recent usage
- **Amount-based heuristics**: Small amounts default toward Food, medium toward Shopping, large toward Bills — as a fallback
- **Entirely on-device**: No network calls needed. All mappings stored locally via SwiftData

## Design

- A new `MerchantCategoryMapping` data model stores learned merchant→category pairs in SwiftData
- The `CategoryMLEngine` service provides instant suggestion lookups (under 100ms)
- Smart suggestion pills appear at the top of the category selector in the transaction entry sheet, highlighted with a sparkle icon and the app's purple accent
- The "Always categorize as…?" confirmation appears as a subtle inline banner after a user changes a category, styled with the dark card background and rounded corners
- Updated category pills use each category's unique emoji alongside the SF Symbol icon for quick visual scanning

## Screens & Changes

- **Transaction Entry Sheet**: Smart suggestion row upgraded to show top 3 engine-powered suggestions instead of simple amount matching; note field text is used for merchant matching
- **Add Expense / Add Income Sheets**: Category grid updated to use the expanded 15-category set with new emojis and colors
- **Transaction Detail (inline editing)**: When a user changes a category, a confirmation prompt offers to learn the mapping and apply retroactively
- **No new screens**: All changes integrate into existing transaction entry and editing flows
