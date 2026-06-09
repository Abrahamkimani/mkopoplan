//
//  LoanResultsView.swift
//  mkopoplan
//

import SwiftUI
import Charts

struct LoanResultsView: View {
    let result: LoanResult

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ResultCard(
                    title: "Monthly EMI",
                    value: CurrencyFormatter.string(from: result.monthlyEMI),
                    icon: "calendar",
                    accentColor: AppTheme.accent
                )
                ResultCard(
                    title: "Total Interest",
                    value: CurrencyFormatter.string(from: result.totalInterest),
                    icon: "percent",
                    accentColor: AppTheme.interest
                )
                ResultCard(
                    title: "Total Payable",
                    value: CurrencyFormatter.string(from: result.totalAmount),
                    icon: "banknote",
                    accentColor: AppTheme.secondaryAccent
                )
                ResultCard(
                    title: "Tenure",
                    value: "\(result.tenureMonths) months",
                    icon: "clock",
                    accentColor: .secondary
                )
            }

            PrincipalInterestChartView(
                principal: result.input.principal,
                totalInterest: result.totalInterest
            )
        }
    }
}

struct PrincipalInterestChartView: View {
    let principal: Decimal
    let totalInterest: Decimal

    private var chartData: [ChartSegment] {
        [
            ChartSegment(category: "Principal", amount: principal, color: AppTheme.principal),
            ChartSegment(category: "Interest", amount: totalInterest, color: AppTheme.interest)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Principal vs Interest")
                .font(.headline)

            Chart(chartData) { segment in
                SectorMark(
                    angle: .value("Amount", segment.amountDouble),
                    innerRadius: .ratio(0.55),
                    angularInset: 1.5
                )
                .foregroundStyle(segment.color)
                .cornerRadius(4)
            }
            .frame(minHeight: 160, idealHeight: 200)

            HStack(spacing: 16) {
                ForEach(chartData) { segment in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(segment.color)
                            .frame(width: 10, height: 10)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(segment.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(CurrencyFormatter.string(from: segment.amount))
                                .font(.caption.weight(.medium))
                        }
                    }
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(chartAccessibilityLabel)
    }

    private var chartAccessibilityLabel: String {
        let principalText = CurrencyFormatter.string(from: principal)
        let interestText = CurrencyFormatter.string(from: totalInterest)
        return "Principal \(principalText), Interest \(interestText)"
    }
}

private struct ChartSegment: Identifiable {
    let id = UUID()
    let category: String
    let amount: Decimal
    let color: Color

    var amountDouble: Double {
        (amount as NSDecimalNumber).doubleValue
    }
}
