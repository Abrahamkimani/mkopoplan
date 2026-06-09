//
//  LoanComparisonView.swift
//  mkopoplan
//

import SwiftUI

struct LoanComparisonView: View {
    @Bindable var viewModel: LoanComparisonViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(viewModel.scenarios.indices, id: \.self) { index in
                    ComparisonScenarioCard(
                        scenario: $viewModel.scenarios[index],
                        isBestEMI: viewModel.lowestEMIScenario?.id == viewModel.scenarios[index].id
                            && viewModel.hasAnyResult
                    )
                }

                if viewModel.scenarios.count < 3 {
                    Button {
                        viewModel.addScenario()
                    } label: {
                        Label("Add Option", systemImage: "plus.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    viewModel.compareAll()
                } label: {
                    Label("Compare All", systemImage: "arrow.left.arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .controlSize(.large)

                if viewModel.hasAnyResult {
                    comparisonSummary
                }
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
        .navigationTitle("Compare Loans")
    }

    private var comparisonSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comparison Summary")
                .font(.headline)

            if let best = viewModel.lowestEMIScenario, let result = best.result {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    VStack(alignment: .leading) {
                        Text("Lowest EMI: \(best.name)")
                            .font(.subheadline.weight(.semibold))
                        Text(CurrencyFormatter.string(from: result.monthlyEMI))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }

            ForEach(viewModel.scenarios.filter { $0.result != nil }) { scenario in
                if let result = scenario.result {
                    HStack {
                        Text(scenario.name)
                            .font(.subheadline)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(CurrencyFormatter.string(from: result.monthlyEMI))
                                .font(.subheadline.weight(.medium))
                            Text("Interest: \(CurrencyFormatter.string(from: result.totalInterest))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

private struct ComparisonScenarioCard: View {
    @Binding var scenario: LoanComparisonScenario
    let isBestEMI: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Name", text: $scenario.name)
                    .font(.headline)

                if isBestEMI {
                    Label("Best EMI", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.yellow)
                }
            }

            VStack(spacing: 0) {
                comparisonField(title: "Principal") {
                    CurrencyTextField(title: "Amount", text: $scenario.principalText)
                }
                Divider().padding(.leading, 12)
                comparisonField(title: "Interest Rate") {
                    PercentTextField(title: "Rate", text: $scenario.interestRateText)
                }
                Divider().padding(.leading, 12)
                comparisonField(title: "Tenure") {
                    HStack {
                        NumericTextField(title: "Duration", text: $scenario.tenureText)
                        Picker("Unit", selection: $scenario.tenureUnit) {
                            ForEach(TenureUnit.allCases) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(maxWidth: 140)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )

            if let error = scenario.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let result = scenario.result {
                HStack {
                    VStack(alignment: .leading) {
                        Text("EMI")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.string(from: result.monthlyEMI))
                            .font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total Interest")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.string(from: result.totalInterest))
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(isBestEMI ? Color.yellow.opacity(0.6) : Color.clear, lineWidth: 2)
        )
    }

    private func comparisonField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            content()
        }
        .padding(12)
    }
}
