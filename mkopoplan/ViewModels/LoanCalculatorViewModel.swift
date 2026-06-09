//
//  LoanCalculatorViewModel.swift
//  mkopoplan
//

import Foundation
import Observation

enum CalculatorViewState: Equatable {
    case idle
    case loading
    case success(LoanResult)
    case error(String)
}

@MainActor
@Observable
final class LoanCalculatorViewModel {
    var principalText = ""
    var interestRateText = ""
    var tenureText = ""
    var tenureUnit: TenureUnit = .years

    private(set) var viewState: CalculatorViewState = .idle
    private(set) var cachedResult: LoanResult?

    private let calculator: LoanCalculatorServiceProtocol
    private var lastCalculatedInput: LoanInput?

    init(calculator: LoanCalculatorServiceProtocol? = nil) {
        self.calculator = calculator ?? LoanCalculatorService()
    }

    var hasResult: Bool {
        if case .success = viewState { return true }
        return false
    }

    var currentResult: LoanResult? {
        if case .success(let result) = viewState { return result }
        return cachedResult
    }

    var inputsChangedSinceCalculation: Bool {
        guard lastCalculatedInput != nil, hasResult else { return false }

        switch currentValidatedInput {
        case .success(let input):
            return input != lastCalculatedInput
        case .failure:
            return true
        }
    }

    private var currentValidatedInput: Result<LoanInput, LoanValidationError> {
        LoanInputValidator.validate(
            principalText: principalText,
            interestRateText: interestRateText,
            tenureText: tenureText,
            tenureUnit: tenureUnit
        )
    }

    func calculate() {
        switch LoanInputValidator.validate(
            principalText: principalText,
            interestRateText: interestRateText,
            tenureText: tenureText,
            tenureUnit: tenureUnit
        ) {
        case .failure(let error):
            viewState = .error(error.localizedDescription)
            cachedResult = nil
        case .success(let input):
            performCalculation(for: input)
        }
    }

    func loadSavedCalculation(_ saved: SavedLoanCalculation) {
        principalText = "\(saved.principal)"
        interestRateText = "\(saved.annualInterestRate)"
        tenureText = "\(saved.tenureValue)"
        tenureUnit = saved.tenureUnit

        let input = saved.loanInput
        let schedule = calculator.generateAmortizationSchedule(for: input, emi: saved.emi)
        let result = saved.toLoanResult(schedule: schedule)

        cachedResult = result
        lastCalculatedInput = input
        viewState = .success(result)
    }

    func loadFromInput(_ input: LoanInput) {
        principalText = "\(input.principal)"
        interestRateText = "\(input.annualInterestRate)"
        tenureText = "\(input.tenureValue)"
        tenureUnit = input.tenureUnit
        performCalculation(for: input)
    }

    func reset() {
        principalText = ""
        interestRateText = ""
        tenureText = ""
        tenureUnit = .years
        viewState = .idle
        cachedResult = nil
        lastCalculatedInput = nil
    }

    func clearError() {
        if case .error = viewState {
            viewState = cachedResult.map { .success($0) } ?? .idle
        }
    }

    /// Returns cached schedule when inputs haven't changed; otherwise recalculates.
    func amortizationSchedule() -> [AmortizationEntry] {
        guard let result = currentResult else { return [] }

        if let lastInput = lastCalculatedInput, lastInput == result.input {
            return result.schedule
        }

        return result.schedule
    }

    private func performCalculation(for input: LoanInput) {
        viewState = .loading

        // Avoid redundant schedule generation when inputs are unchanged.
        if let lastInput = lastCalculatedInput,
           lastInput == input,
           let cached = cachedResult {
            viewState = .success(cached)
            return
        }

        let result = calculator.calculateLoan(for: input)
        cachedResult = result
        lastCalculatedInput = input
        viewState = .success(result)
    }
}
