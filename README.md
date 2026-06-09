# Mkopo Plan

A SwiftUI loan calculator and amortization app built with MVVM and SwiftData. Enter a loan amount, interest rate, and tenure to get monthly EMI, total interest, a full repayment schedule, and saved calculation history.

<p align="center">
  <img src="docs/screenshots/app-icon.png" alt="Mkopo Plan app icon" width="120" />
</p>

## Screenshots

| Calculator | Compare |
|:---:|:---:|
| <img src="docs/screenshots/calculator.png" alt="Calculator screen" width="280" /> | <img src="docs/screenshots/compare.png" alt="Compare loans screen" width="280" /> |

| History | Settings |
|:---:|:---:|
| <img src="docs/screenshots/history.png" alt="Saved calculations history" width="280" /> | <img src="docs/screenshots/settings.png" alt="Settings screen" width="280" /> |

## Requirements

- macOS with **Xcode 26.1** or later
- iOS **26.1** simulator or physical device
- Apple Developer account (for running on a real device)

## How to Run

1. Clone the repository and open the project in Xcode:

   ```bash
   git clone <https://github.com/Abrahamkimani/mkopoplan.git>
   cd mkopoplan
   open mkopoplan.xcodeproj
   ```

2. Select the **mkopoplan** scheme and choose a simulator (e.g. iPhone 17) or your connected device.

3. Press **⌘R** to build and run.

### Run unit tests

```bash
xcodebuild -scheme mkopoplan \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:mkopoplanTests
```

Or in Xcode: **⌘U**.

## Architecture Overview

The app follows **MVVM** with a thin persistence layer and a dedicated calculation service.

```
mkopoplan/
├── Models/           # LoanInput, LoanResult, AmortizationEntry, SwiftData entities
├── Services/         # LoanCalculatorService (EMI + amortization logic)
├── ViewModels/       # @Observable view models, cached results
├── Views/            # SwiftUI screens and reusable components
├── Persistence/      # SwiftData repository + ModelContainer setup
└── Utilities/        # Validation, currency formatting, theming
```

**Data flow**

1. The user enters loan details in `LoanCalculatorView`.
2. `LoanCalculatorViewModel` validates input via `LoanInputValidator`.
3. `LoanCalculatorService` computes EMI and builds the amortization schedule using `Decimal` arithmetic.
4. Results are shown in the UI; the user can save them through `SavedCalculationRepository` (SwiftData).
5. Saved loans appear in `HistoryView` and can be reopened in the calculator.

**Key design choices**

- Calculation logic lives in `LoanCalculatorService`, not in views or view models, so it stays testable and reusable (e.g. loan comparison uses the same service).
- Amortization schedules are generated once per calculation and cached in `LoanResult` to avoid redundant work on navigation.
- SwiftData stores summary fields only (principal, rate, tenure, EMI, totals, date) — not the full schedule. Schedules are regenerated when a saved item is opened.

## Product Scope

Mkopo Plan is a **loan calculator and planner** — users explore what a loan would cost, compare options, and save calculations locally. It is not a full customer lending app (apply loan, confirm disbursement, active loan dashboard, submit requests to a backend).

Reference designs for a production lending product (home dashboard, loan product cards, apply/confirm flows, success modals) share the same domain — loans, KES, green branding, repayment schedules — but target **loan origination and account management**. This build focuses on the **financial engine** behind those screens.

| Question | Category | Summary |
|----------|----------|---------|
| What is the product? | **Assumption** | Calculator and comparison tool, not loan submission. |
| Why no apply/dashboard UI? | **Trade-off** | Depth on correct EMI math and architecture over a full lending funnel. |
| What can't the app do today? | **Limitation** | No loan submission, active balances, disbursement accounts, or backend APIs. |

## Assumptions

| Area | Assumption |
|------|------------|
| Product scope | Users are **planning and comparing** loans, not applying for or managing live accounts. |
| Backend | **No server** — no user profiles, loan limits, disbursement accounts, or request submission. |
| Currency | Amounts are in **Kenyan Shillings (KES)** with `en_KE` locale formatting. |
| Repayment | Fixed monthly EMI using the standard reducing-balance formula. |
| Interest | Annual rate entered as a percentage; converted to a monthly rate internally. |
| Tenure | User enters months or years; all calculations use months (max **360**). |
| Zero interest | EMI = principal ÷ months; no interest portion in the schedule. |
| Payments | One payment per month; no fees, penalties, or grace periods. |
| Schedule dates | Amortization shows **payment numbers**, not calendar instalment dates. |
| Persistence | One saved record per user action; no cloud sync or export. |
| Comparison | Up to three loan options; lowest EMI is highlighted after comparison. |

## Trade-offs

Deliberate choices made to keep the submission focused and maintainable:

- **Calculator depth over lending breadth** — invested in `Decimal`-based EMI logic, amortization caching, unit tests, and MVVM separation instead of building apply-loan, confirmation, and dashboard flows.
- **Local SwiftData over APIs** — saved calculations work offline with no backend dependency; active loan balances and loan limits would require server integration.
- **Single calculator flow over product catalog** — one input model (principal, rate, tenure) instead of multiple product types (e.g. Salary E-Loan, BNPL, Stock Loan) with different rules.
- **Simpler UI over full fintech onboarding** — green branding and clear layouts without matching every screen in a production lending mock.

**What works well as a result**

- `Decimal` is used for money calculations instead of `Double`, which reduces floating-point drift on long tenures.
- `List` backs the amortization table for efficient scrolling up to 360 rows.
- Input validation runs before any calculation; errors are shown inline.
- If disk storage fails on launch, the app falls back to in-memory SwiftData and shows a warning rather than crashing.

## Limitations

What the current build cannot do:

- **No loan origination** — cannot apply for, confirm, or submit a loan request.
- **No active loan dashboard** — cannot display live balances, next payment dates, or instalment counts from an account system.
- **No disbursement** — no bank account selection or payout flow.
- **No loan product catalog** — no predefined products with limits, rates, or eligibility rules.
- **No schedule persistence** — reopening a saved loan regenerates the amortization table from stored inputs. This keeps the database small but means saved EMI must match recalculated EMI for consistency.
- **KES only** — currency is fixed to Kenyan Shillings. Multi-currency support would need a settings picker and formatter changes.
- **No extra costs** — processing fees, insurance, or balloon payments are not modelled.
- **Rounding** — amounts are rounded to two decimal places (banker's rounding). The final payment is adjusted so the balance reaches zero.
- **Comparison is manual** — users tap "Compare All"; there is no live update as they type.
- **iOS 26.1 minimum** — targets the latest SDK; not tested on older iOS versions.

A future version could reuse the same `LoanCalculatorService` behind apply-loan and active-loan screens from a full product design.

## Features

- Loan EMI calculator with principal vs interest chart
- Full amortization schedule
- Save and revisit past calculations
- Side-by-side loan comparison (2–3 options)
- Light / dark / system theme
- VoiceOver labels and Dynamic Type-friendly text styles
- Keyboard Done button and dismiss-on-tab-switch


