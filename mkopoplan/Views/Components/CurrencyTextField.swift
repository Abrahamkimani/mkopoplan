//
//  CurrencyTextField.swift
//  mkopoplan
//

import SwiftUI

struct CurrencyTextField: View {
    let title: String
    @Binding var text: String
    var prefix: String = CurrencyFormatter.currencySymbol

    var body: some View {
        HStack {
            Text(prefix)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "Empty" : "\(prefix) \(text)")
    }
}

struct PercentTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        HStack {
            TextField(title, text: $text)
                .keyboardType(.decimalPad)
            Text("%")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(text.isEmpty ? "Empty" : "\(text) percent")
    }
}

struct NumericTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .keyboardType(.numberPad)
            .accessibilityLabel(title)
            .accessibilityValue(text.isEmpty ? "Empty" : text)
    }
}
