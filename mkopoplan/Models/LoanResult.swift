//
//  LoanResult.swift
//  mkopoplan
//

import Foundation

struct LoanResult: Equatable, Sendable {
    let input: LoanInput
    let monthlyEMI: Decimal
    let totalInterest: Decimal
    let totalAmount: Decimal
    let schedule: [AmortizationEntry]

    var tenureMonths: Int { input.tenureMonths }
}
