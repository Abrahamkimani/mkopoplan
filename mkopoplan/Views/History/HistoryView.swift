//
//  HistoryView.swift
//  mkopoplan
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedLoanCalculation.dateCreated, order: .reverse)
    private var savedCalculations: [SavedLoanCalculation]

    @Bindable var calculatorViewModel: LoanCalculatorViewModel
    @Binding var selectedTab: Int

    @State private var deleteErrorMessage: String?

    var body: some View {
        Group {
            if savedCalculations.isEmpty {
                EmptyStateView(
                    systemImage: "clock.arrow.circlepath",
                    title: "No saved calculations yet",
                    message: "Save a loan from the calculator and it will show up here."
                )
            } else {
                List {
                    ForEach(savedCalculations) { calculation in
                        NavigationLink {
                            SavedCalculationDetailView(
                                calculation: calculation,
                                calculatorViewModel: calculatorViewModel,
                                selectedTab: $selectedTab
                            )
                        } label: {
                            HistoryRowView(calculation: calculation)
                        }
                    }
                    .onDelete(perform: deleteCalculations)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("History")
        .toolbar {
            if !savedCalculations.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .alert("Delete Failed", isPresented: Binding(
            get: { deleteErrorMessage != nil },
            set: { if !$0 { deleteErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage ?? "")
        }
    }

    private func deleteCalculations(at offsets: IndexSet) {
        let repository = SavedCalculationRepository(modelContext: modelContext)
        let toDelete = offsets.map { savedCalculations[$0] }

        do {
            try repository.deleteAll(toDelete)
        } catch {
            deleteErrorMessage = error.localizedDescription
        }
    }
}

struct HistoryRowView: View {
    let calculation: SavedLoanCalculation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(CurrencyFormatter.string(from: calculation.principal))
                    .font(.headline)
                Spacer()
                Text(CurrencyFormatter.string(from: calculation.emi))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
            }

            HStack {
                Label(
                    CurrencyFormatter.percentString(from: calculation.annualInterestRate),
                    systemImage: "percent"
                )
                Text("•")
                Text("\(calculation.tenureValue) \(calculation.tenureUnit.displayName.lowercased())")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(calculation.dateCreated, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

struct SavedCalculationDetailView: View {
    let calculation: SavedLoanCalculation
    @Bindable var calculatorViewModel: LoanCalculatorViewModel
    @Binding var selectedTab: Int

    @State private var result: LoanResult?

    private let calculator = LoanCalculatorService()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let result {
                    LoanResultsView(result: result)

                    NavigationLink {
                        AmortizationScheduleView(schedule: result.schedule)
                    } label: {
                        Label("View Amortization Schedule", systemImage: "tablecells")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accent)

                    Button {
                        calculatorViewModel.loadSavedCalculation(calculation)
                        selectedTab = 0
                    } label: {
                        Label("Reopen in Calculator", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                } else {
                    LoadingView(message: "Loading calculation…")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .dismissKeyboardOnInteraction()
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Saved Loan")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadResult()
        }
    }

    private func loadResult() {
        let schedule = calculator.generateAmortizationSchedule(
            for: calculation.loanInput,
            emi: calculation.emi
        )
        result = calculation.toLoanResult(schedule: schedule)
    }
}
