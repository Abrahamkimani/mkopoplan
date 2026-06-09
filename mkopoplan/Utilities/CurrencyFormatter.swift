//
//  CurrencyFormatter.swift
//  mkopoplan
//

import Foundation

enum CurrencyFormatter {
    private static let locale = Locale(identifier: "en_KE")

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = "KES"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static var currencyCode: String { "KES" }

    static var currencySymbol: String {
        formatter.currencySymbol ?? "KES"
    }

    static func string(from value: Decimal) -> String {
        formatter.string(from: value as NSDecimalNumber) ?? "\(currencyCode) \(value)"
    }

    static func percentString(from value: Decimal) -> String {
        let number = (value as NSDecimalNumber).doubleValue
        return String(format: "%.2f%%", number)
    }
}
