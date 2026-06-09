//
//  LoanComparisonViewModel.swift
//  mkopoplan
//

import Foundation
import Observation

struct LoanComparisonScenario: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var principalText: String
    var interestRateText: String
    var tenureText: String
    var tenureUnit: TenureUnit
    var result: LoanResult?
    var errorMessage: String?

    init(
        name: String,
        principalText: String = "",
        interestRateText: String = "",
        tenureText: String = "",
        tenureUnit: TenureUnit = .years
    ) {
        self.name = name
        self.principalText = principalText
        self.interestRateText = interestRateText
        self.tenureText = tenureText
        self.tenureUnit = tenureUnit
    }
}

@MainActor
@Observable
final class LoanComparisonViewModel {
    var scenarios: [LoanComparisonScenario] = [
        LoanComparisonScenario(name: "Option A"),
        LoanComparisonScenario(name: "Option B")
    ]

    private let calculator: LoanCalculatorServiceProtocol

    init(calculator: LoanCalculatorServiceProtocol? = nil) {
        self.calculator = calculator ?? LoanCalculatorService()
    }

    func addScenario() {
        guard scenarios.count < 3 else { return }
        let label = ["A", "B", "C"][scenarios.count]
        scenarios.append(LoanComparisonScenario(name: "Option \(label)"))
    }

    func removeScenario(at index: Int) {
        guard scenarios.count > 2 else { return }
        scenarios.remove(at: index)
    }

    func compareAll() {
        for index in scenarios.indices {
            compareScenario(at: index)
        }
    }

    func compareScenario(at index: Int) {
        let scenario = scenarios[index]

        switch LoanInputValidator.validate(
            principalText: scenario.principalText,
            interestRateText: scenario.interestRateText,
            tenureText: scenario.tenureText,
            tenureUnit: scenario.tenureUnit
        ) {
        case .failure(let error):
            scenarios[index].errorMessage = error.localizedDescription
            scenarios[index].result = nil
        case .success(let input):
            scenarios[index].result = calculator.calculateLoan(for: input)
            scenarios[index].errorMessage = nil
        }
    }

    var hasAnyResult: Bool {
        scenarios.contains { $0.result != nil }
    }

    var lowestEMIScenario: LoanComparisonScenario? {
        scenarios
            .compactMap { scenario -> (LoanComparisonScenario, Decimal)? in
                guard let emi = scenario.result?.monthlyEMI else { return nil }
                return (scenario, emi)
            }
            .min(by: { $0.1 < $1.1 })?
            .0
    }
}
