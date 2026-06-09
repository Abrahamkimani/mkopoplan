//
//  LoanCalculatorView.swift
//  mkopoplan
//

import SwiftUI
import SwiftData

struct LoanCalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: LoanCalculatorViewModel

    @State private var showSaveConfirmation = false
    @State private var saveErrorMessage: String?

    private var actionButtonTitle: String {
        viewModel.hasResult && viewModel.inputsChangedSinceCalculation
            ? "Recalculate"
            : "Calculate EMI"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                inputSection

                if case .error(let message) = viewModel.viewState {
                    ErrorBannerView(message: message) {
                        viewModel.clearError()
                    }
                }

                if viewModel.hasResult && viewModel.inputsChangedSinceCalculation {
                    StaleResultsBanner()
                }

                Button {
                    KeyboardDismiss.dismiss()
                    viewModel.calculate()
                } label: {
                    Label(actionButtonTitle, systemImage: "function")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .controlSize(.large)
                .accessibilityLabel(actionButtonTitle)
                .accessibilityHint("Calculates monthly payment and loan summary")

                resultsSection
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .dismissKeyboardOnInteraction()
        .simultaneousGesture(
            TapGesture().onEnded {
                KeyboardDismiss.dismiss()
            }
        )
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mkopo Plan")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.hasResult {
                    Menu {
                        Button {
                            saveCalculation()
                        } label: {
                            Label("Save Calculation", systemImage: "square.and.arrow.down")
                        }

                        NavigationLink {
                            if let result = viewModel.currentResult {
                                AmortizationScheduleView(schedule: result.schedule)
                            }
                        } label: {
                            Label("View Schedule", systemImage: "tablecells")
                        }

                        Button(role: .destructive) {
                            viewModel.reset()
                        } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More options")
                }
            }
        }
        .alert("Saved", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Calculation saved to history.")
        }
        .alert("Save Failed", isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { if !$0 { saveErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage ?? "")
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Loan Details")
                .font(.headline)

            VStack(spacing: 0) {
                inputRow(title: "Principal Amount") {
                    CurrencyTextField(title: "Principal amount in Kenyan shillings", text: $viewModel.principalText)
                }

                Divider().padding(.leading, 16)

                inputRow(title: "Annual Interest Rate") {
                    PercentTextField(title: "Annual interest rate", text: $viewModel.interestRateText)
                }

                Divider().padding(.leading, 16)

                inputRow(title: "Loan Tenure") {
                    HStack {
                        NumericTextField(title: "Loan duration", text: $viewModel.tenureText)
                        Picker("Tenure unit", selection: $viewModel.tenureUnit) {
                            ForEach(TenureUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 160)
                        .accessibilityLabel("Tenure unit")
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilitySortPriority(1)
    }

    private func inputRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            content()
        }
        .padding()
    }

    @ViewBuilder
    private var resultsSection: some View {
        switch viewModel.viewState {
        case .idle:
            EmptyStateView(
                systemImage: "plus.forwardslash.minus",
                title: "Ready to Calculate",
                message: "Enter your loan details and tap Calculate EMI to see results."
            )
            .padding(.top, 8)

        case .loading:
            LoadingView()

        case .success(let result):
            VStack(alignment: .leading, spacing: 12) {
                Text("Results")
                    .font(.headline)

                LoanResultsView(result: result)
                    .accessibilitySortPriority(0)

                NavigationLink {
                    AmortizationScheduleView(schedule: result.schedule)
                } label: {
                    Label("View Full Amortization Schedule", systemImage: "tablecells")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.accent)
            }

        case .error:
            EmptyView()
        }
    }

    private func saveCalculation() {
        guard let result = viewModel.currentResult else { return }
        let repository = SavedCalculationRepository(modelContext: modelContext)

        do {
            try repository.save(result: result)
            showSaveConfirmation = true
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}
