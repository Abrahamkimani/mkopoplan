//
//  AmortizationScheduleView.swift
//  mkopoplan
//

import SwiftUI

struct AmortizationScheduleView: View {
    let schedule: [AmortizationEntry]

    var body: some View {
        Group {
            if schedule.isEmpty {
                EmptyStateView(
                    systemImage: "tablecells",
                    title: "No Schedule",
                    message: "Calculate a loan to view the amortization schedule."
                )
            } else {
                List {
                    Section {
                        scheduleHeader
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    Section {
                        ForEach(schedule) { entry in
                            AmortizationRowView(entry: entry)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Amortization")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scheduleHeader: some View {
        HStack {
            Text("#")
                .frame(width: 28, alignment: .leading)
            Text("EMI")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Interest")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Principal")
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text("Balance")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
        .textCase(.uppercase)
    }
}

struct AmortizationRowView: View {
    let entry: AmortizationEntry

    var body: some View {
        HStack(spacing: 4) {
            Text("\(entry.paymentNumber)")
                .font(.caption.monospacedDigit())
                .frame(width: 28, alignment: .leading)
                .foregroundStyle(.secondary)

            Text(CurrencyFormatter.string(from: entry.emi))
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(CurrencyFormatter.string(from: entry.interestPortion))
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(AppTheme.interest)

            Text(CurrencyFormatter.string(from: entry.principalPortion))
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(AppTheme.principal)

            Text(CurrencyFormatter.string(from: entry.remainingBalance))
                .font(.caption.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var rowAccessibilityLabel: String {
        "Payment \(entry.paymentNumber). EMI \(CurrencyFormatter.string(from: entry.emi)). Interest \(CurrencyFormatter.string(from: entry.interestPortion)). Principal \(CurrencyFormatter.string(from: entry.principalPortion)). Balance \(CurrencyFormatter.string(from: entry.remainingBalance))."
    }
}
