//
//  StaleResultsBanner.swift
//  mkopoplan
//

import SwiftUI

struct StaleResultsBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundStyle(AppTheme.accent)
            Text("Loan details changed. Recalculate to update results.")
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.accent.opacity(0.1))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loan details changed. Recalculate to update results.")
    }
}
