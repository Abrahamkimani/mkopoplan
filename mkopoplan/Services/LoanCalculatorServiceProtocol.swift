//
//  LoanCalculatorServiceProtocol.swift
//  mkopoplan
//

import Foundation

protocol LoanCalculatorServiceProtocol: Sendable {
    func calculateEMI(for input: LoanInput) -> Decimal
    func calculateLoan(for input: LoanInput) -> LoanResult
    func generateAmortizationSchedule(for input: LoanInput, emi: Decimal) -> [AmortizationEntry]
}
