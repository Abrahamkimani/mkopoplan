//
//  mkopoplanTests.swift
//  mkopoplanTests
//

import XCTest
@testable import mkopoplan

final class mkopoplanTests: XCTestCase {
    func testTenureUnitConversion() {
        XCTAssertEqual(TenureUnit.years.toMonths(5), 60)
        XCTAssertEqual(TenureUnit.months.toMonths(24), 24)
    }
}
