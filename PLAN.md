# Splurj: 7 Bug Fixes + UX Improvements

## Bug 1: Currency Selection Not Applying Globally
**Problem:** Users pick a currency during onboarding, but all amounts still show "$" and "USD" everywhere.

**Fix:**
- Replace all hardcoded "$" symbols and "USD" currency codes across ~30 files with the user's chosen currency
- Update the shared amount display component to use the selected currency
- Files affected: Wallet, Home, Budget Analytics, Add Expense, Recurring Expenses, Ghost Budget, Milestone Share, Weekly Summary, Character View, Evening Reflection, Money Wrapped, Spending Timeline, Quick Transaction, Add Budget, Add Income, Budget Detail, Spending Autopsy, Log Win, and more

---

## Bug 2: Impulse Cost Calculator Shows Same Amounts
**Problem:** "Without Splurj" and "With Splurj" columns show the same number when a user has only resisted impulses (never "gave in").

**Fix:**
- "Without Splurj" will show the total of ALL impulse urges (what you would have spent without the app)
- "With Splurj" will show only what you actually spent (gave in amounts)
- Add a "You saved" indicator showing the difference between the two

---

## Bug 3: 1-Year Projection is Static
**Problem:** The projection uses a hardcoded daily target from onboarding instead of actual savings data.

**Fix:**
- Calculate the real average daily savings based on actual user behavior
- Show how many days of data the average is based on
- Add an "if you save more" optimistic scenario line
- Numbers animate smoothly when values change

---

## Bug 4: Recurring Expenses & Ghost Budget Buttons Not Working
**Problem:** Tapping "Recurring Expenses" or "Ghost Budget" from the Budget Analytics screen does nothing due to nested navigation issues.

**Fix:**
- Change these from navigation links to sheet presentations
- Each opens in its own full sheet with a close button
- Works reliably regardless of how Budget Analytics was opened

---

## Bug 5: Expenses Added on Home Not Showing in Budget
**Problem:** Expenses added from Home don't appear in Budget because category names don't match exactly between transactions and budgets.

**Fix:**
- Ensure budget filtering matches transaction categories correctly (case-insensitive comparison)
- Both the Home screen and Budget Analytics will use the same matching logic

---

## Bug 6: No Back/Exit Button on Tools Sub-Pages
**Problem:** Opening any tool from the Tools tab shows a full-screen view with no way to go back — users get stuck.

**Fix:**
- Every tool opened from the Tools tab will get an X (close) button in the top-left corner
- Each tool view is wrapped in its own navigation container so internal links also work
- Consistent close button styling across all 13 tool views

---

## Bug 7: Wallet — Add Savings Trend Graph + Future Prediction
**Problem:** The Wallet only shows a basic weekly bar chart with no trend or projection visualization.

**Fix:**
- Add a new "Savings Trend" line chart showing the last 6 months of actual savings
- Include a dashed projection line for the next 3 months based on current trends
- Gradient fill under the actual savings line for visual appeal
- Legend showing "Actual" vs "Projected"
- Placed above the existing weekly chart for better visual hierarchy
