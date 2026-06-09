//
//  LoanInput.swift
//  mkopoplan
//

import Foundation

struct LoanInput: Equatable, Hashable, Sendable {
    var principal: Decimal
    var annualInterestRate: Decimal
    var tenureValue: Int
    var tenureUnit: TenureUnit

    nonisolated var tenureMonths: Int {
        tenureUnit.toMonths(tenureValue)
    }

    init(
        principal: Decimal = 0,
        annualInterestRate: Decimal = 0,
        tenureValue: Int = 0,
        tenureUnit: TenureUnit = .years
    ) {
        self.principal = principal
        self.annualInterestRate = annualInterestRate
        self.tenureValue = tenureValue
        self.tenureUnit = tenureUnit
    }
}
