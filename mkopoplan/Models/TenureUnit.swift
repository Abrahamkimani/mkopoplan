//
//  TenureUnit.swift
//  mkopoplan
//

import Foundation

enum TenureUnit: String, CaseIterable, Identifiable, Codable {
    case months
    case years

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .months: "Months"
        case .years: "Years"
        }
    }

    nonisolated func toMonths(_ value: Int) -> Int {
        switch self {
        case .months: value
        case .years: value * 12
        }
    }
}
