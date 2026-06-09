//
//  LoanCalculatorService.swift
//  mkopoplan
//

import Foundation

/// Standard EMI formula: EMI = [P × R × (1+R)^N] / [(1+R)^N – 1]
/// Where P = principal, R = monthly rate, N = tenure in months.
struct LoanCalculatorService: LoanCalculatorServiceProtocol, Sendable {
    nonisolated init() {}

    nonisolated func calculateLoan(for input: LoanInput) -> LoanResult {
        let emi = calculateEMI(for: input)
        let schedule = generateAmortizationSchedule(for: input, emi: emi)
        let totalAmount = schedule.reduce(Decimal.zero) { $0 + $1.emi }.roundedCurrency
        let totalInterest = (totalAmount - input.principal).roundedCurrency

        return LoanResult(
            input: input,
            monthlyEMI: emi,
            totalInterest: totalInterest,
            totalAmount: totalAmount,
            schedule: schedule
        )
    }

    nonisolated func calculateEMI(for input: LoanInput) -> Decimal {
        let principal = input.principal
        let months = input.tenureMonths

        guard months > 0 else { return 0 }

        // Zero-interest edge case: equal principal payments.
        if input.annualInterestRate == 0 {
            return (principal / Decimal(months)).roundedCurrency
        }

        let monthlyRate = input.annualInterestRate / Decimal(1200)
        let compoundFactor = (1 + monthlyRate).raisedToPower(months)
        let numerator = principal * monthlyRate * compoundFactor
        let denominator = compoundFactor - 1

        guard denominator != 0 else {
            return (principal / Decimal(months)).roundedCurrency
        }

        return (numerator / denominator).roundedCurrency
    }

    nonisolated func generateAmortizationSchedule(for input: LoanInput, emi: Decimal) -> [AmortizationEntry] {
        let months = input.tenureMonths
        guard months > 0 else { return [] }

        var remainingBalance = input.principal
        let monthlyRate = input.annualInterestRate == 0
            ? Decimal.zero
            : input.annualInterestRate / Decimal(1200)

        var schedule: [AmortizationEntry] = []
        schedule.reserveCapacity(months)

        for paymentNumber in 1...months {
            let interestPortion: Decimal
            if monthlyRate == 0 {
                interestPortion = 0
            } else {
                interestPortion = (remainingBalance * monthlyRate).roundedCurrency
            }

            var principalPortion = (emi - interestPortion).roundedCurrency
            var paymentEMI = emi

            // Final payment adjustment to clear rounding residue.
            if paymentNumber == months {
                principalPortion = remainingBalance
                paymentEMI = (principalPortion + interestPortion).roundedCurrency
                remainingBalance = 0
            } else {
                remainingBalance = (remainingBalance - principalPortion).roundedCurrency
                if remainingBalance < 0 {
                    principalPortion += remainingBalance
                    remainingBalance = 0
                }
            }

            schedule.append(
                AmortizationEntry(
                    id: paymentNumber,
                    paymentNumber: paymentNumber,
                    emi: paymentEMI,
                    interestPortion: interestPortion,
                    principalPortion: principalPortion,
                    remainingBalance: remainingBalance
                )
            )
        }

        return schedule
    }
}
