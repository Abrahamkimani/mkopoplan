//
//  SavedLoanCalculation.swift
//  mkopoplan
//

import Foundation
import SwiftData

@Model
final class SavedLoanCalculation {
    var id: UUID
    var principal: Decimal
    var annualInterestRate: Decimal
    var tenureValue: Int
    var tenureUnitRaw: String
    var emi: Decimal
    var totalInterest: Decimal
    var totalAmount: Decimal
    var dateCreated: Date

    init(
        id: UUID = UUID(),
        principal: Decimal,
        annualInterestRate: Decimal,
        tenureValue: Int,
        tenureUnit: TenureUnit,
        emi: Decimal,
        totalInterest: Decimal,
        totalAmount: Decimal,
        dateCreated: Date = .now
    ) {
        self.id = id
        self.principal = principal
        self.annualInterestRate = annualInterestRate
        self.tenureValue = tenureValue
        self.tenureUnitRaw = tenureUnit.rawValue
        self.emi = emi
        self.totalInterest = totalInterest
        self.totalAmount = totalAmount
        self.dateCreated = dateCreated
    }

    var tenureUnit: TenureUnit {
        TenureUnit(rawValue: tenureUnitRaw) ?? .months
    }

    var loanInput: LoanInput {
        LoanInput(
            principal: principal,
            annualInterestRate: annualInterestRate,
            tenureValue: tenureValue,
            tenureUnit: tenureUnit
        )
    }

    func toLoanResult(schedule: [AmortizationEntry]) -> LoanResult {
        LoanResult(
            input: loanInput,
            monthlyEMI: emi,
            totalInterest: totalInterest,
            totalAmount: totalAmount,
            schedule: schedule
        )
    }
}
