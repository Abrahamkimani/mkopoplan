//
//  LoanInputValidator.swift
//  mkopoplan
//

import Foundation

enum LoanValidationError: LocalizedError, Equatable {
    case emptyPrincipal
    case emptyInterestRate
    case emptyTenure
    case negativePrincipal
    case negativeInterestRate
    case negativeTenure
    case zeroPrincipal
    case zeroTenure
    case tenureExceedsMaximum(maxMonths: Int)

    var errorDescription: String? {
        switch self {
        case .emptyPrincipal, .zeroPrincipal:
            "Enter a valid loan amount."
        case .emptyInterestRate:
            "Enter a valid interest rate."
        case .emptyTenure, .zeroTenure:
            "Enter a valid loan tenure."
        case .negativePrincipal:
            "Loan amount can't be negative."
        case .negativeInterestRate:
            "Interest rate can't be negative."
        case .negativeTenure:
            "Loan tenure can't be negative."
        case .tenureExceedsMaximum(let maxMonths):
            "Tenure can't be longer than \(maxMonths) months."
        }
    }
}

enum LoanInputValidator {
    static let maxTenureMonths = 360

    static func validate(
        principalText: String,
        interestRateText: String,
        tenureText: String,
        tenureUnit: TenureUnit
    ) -> Result<LoanInput, LoanValidationError> {
        let trimmedPrincipal = principalText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = interestRateText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTenure = tenureText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedPrincipal.isEmpty else { return .failure(.emptyPrincipal) }
        guard !trimmedRate.isEmpty else { return .failure(.emptyInterestRate) }
        guard !trimmedTenure.isEmpty else { return .failure(.emptyTenure) }

        guard let principal = Decimal(string: trimmedPrincipal) else {
            return .failure(.emptyPrincipal)
        }
        guard let annualRate = Decimal(string: trimmedRate) else {
            return .failure(.emptyInterestRate)
        }
        guard let tenureValue = Int(trimmedTenure) else {
            return .failure(.emptyTenure)
        }

        if principal < 0 { return .failure(.negativePrincipal) }
        if annualRate < 0 { return .failure(.negativeInterestRate) }
        if tenureValue < 0 { return .failure(.negativeTenure) }
        if principal == 0 { return .failure(.zeroPrincipal) }
        if tenureValue == 0 { return .failure(.zeroTenure) }

        let tenureMonths = tenureUnit.toMonths(tenureValue)
        if tenureMonths > maxTenureMonths {
            return .failure(.tenureExceedsMaximum(maxMonths: maxTenureMonths))
        }

        return .success(
            LoanInput(
                principal: principal,
                annualInterestRate: annualRate,
                tenureValue: tenureValue,
                tenureUnit: tenureUnit
            )
        )
    }

    static func validate(_ input: LoanInput) -> Result<LoanInput, LoanValidationError> {
        validate(
            principalText: "\(input.principal)",
            interestRateText: "\(input.annualInterestRate)",
            tenureText: "\(input.tenureValue)",
            tenureUnit: input.tenureUnit
        )
    }
}
