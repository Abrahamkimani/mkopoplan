//
//  SavedCalculationRepository.swift
//  mkopoplan
//

import Foundation
import SwiftData

@MainActor
final class SavedCalculationRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(result: LoanResult) throws {
        let saved = SavedLoanCalculation(
            principal: result.input.principal,
            annualInterestRate: result.input.annualInterestRate,
            tenureValue: result.input.tenureValue,
            tenureUnit: result.input.tenureUnit,
            emi: result.monthlyEMI,
            totalInterest: result.totalInterest,
            totalAmount: result.totalAmount
        )
        modelContext.insert(saved)
        try modelContext.save()
    }

    func delete(_ calculation: SavedLoanCalculation) throws {
        modelContext.delete(calculation)
        try modelContext.save()
    }

    func deleteAll(_ calculations: [SavedLoanCalculation]) throws {
        calculations.forEach { modelContext.delete($0) }
        try modelContext.save()
    }
}
