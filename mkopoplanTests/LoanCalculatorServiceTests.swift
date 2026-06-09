//
//  LoanCalculatorServiceTests.swift
//  mkopoplanTests
//

import XCTest
@testable import mkopoplan

final class LoanCalculatorServiceTests: XCTestCase {
    private let service = LoanCalculatorService()

    func testEMI_standardLoan() {
        let input = LoanInput(
            principal: 1_000_000,
            annualInterestRate: 8.5,
            tenureValue: 20,
            tenureUnit: .years
        )

        let emi = service.calculateEMI(for: input)
        XCTAssertGreaterThan(emi, 0)

        let result = service.calculateLoan(for: input)
        XCTAssertEqual(result.monthlyEMI, emi)
        XCTAssertEqual(result.schedule.count, 240)
        XCTAssertEqual(result.schedule.last?.remainingBalance, 0)
        XCTAssertGreaterThan(result.totalInterest, 0)
        XCTAssertEqual(result.totalAmount, result.input.principal + result.totalInterest)
    }

    func testEMI_zeroInterest() {
        let input = LoanInput(
            principal: 120_000,
            annualInterestRate: 0,
            tenureValue: 12,
            tenureUnit: .months
        )

        let emi = service.calculateEMI(for: input)
        XCTAssertEqual(emi, 10_000)

        let result = service.calculateLoan(for: input)
        XCTAssertEqual(result.totalInterest, 0)
        XCTAssertEqual(result.totalAmount, 120_000)

        for entry in result.schedule {
            XCTAssertEqual(entry.interestPortion, 0)
            XCTAssertEqual(entry.principalPortion, 10_000)
        }
    }

    func testAmortization_principalPlusInterestEqualsEMI() {
        let input = LoanInput(
            principal: 500_000,
            annualInterestRate: 6.75,
            tenureValue: 15,
            tenureUnit: .years
        )

        let result = service.calculateLoan(for: input)

        for entry in result.schedule {
            let sum = entry.principalPortion + entry.interestPortion
            XCTAssertEqual(sum, entry.emi)
        }
    }

    func testAmortization_maxTenure360Months() {
        let input = LoanInput(
            principal: 250_000,
            annualInterestRate: 5.25,
            tenureValue: 360,
            tenureUnit: .months
        )

        let result = service.calculateLoan(for: input)
        XCTAssertEqual(result.schedule.count, 360)
        XCTAssertEqual(result.schedule.last?.remainingBalance, 0)
    }

    func testValidator_rejectsNegativePrincipal() {
        let result = LoanInputValidator.validate(
            principalText: "-1000",
            interestRateText: "5",
            tenureText: "10",
            tenureUnit: .years
        )

        guard case .failure(let error) = result else {
            return XCTFail("Expected validation failure")
        }
        XCTAssertEqual(error, .negativePrincipal)
    }

    func testValidator_rejectsTenureAbove360Months() {
        let result = LoanInputValidator.validate(
            principalText: "100000",
            interestRateText: "5",
            tenureText: "31",
            tenureUnit: .years
        )

        guard case .failure(let error) = result else {
            return XCTFail("Expected validation failure")
        }
        XCTAssertEqual(error, .tenureExceedsMaximum(maxMonths: 360))
    }

    func testCurrencyFormatter_usesKESFormat() {
        let formatted = CurrencyFormatter.string(from: 50_000)
        XCTAssertTrue(formatted.contains("50"))
        XCTAssertTrue(formatted.uppercased().contains("KES") || formatted.contains("Ksh"))
    }

    func testValidator_acceptsZeroInterest() {
        let result = LoanInputValidator.validate(
            principalText: "50000",
            interestRateText: "0",
            tenureText: "24",
            tenureUnit: .months
        )

        guard case .success(let input) = result else {
            return XCTFail("Expected validation success")
        }
        XCTAssertEqual(input.annualInterestRate, 0)
    }
}
