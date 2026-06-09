//
//  Decimal+Math.swift
//  mkopoplan
//

import Foundation

extension Decimal {
    nonisolated func raisedToPower(_ exponent: Int) -> Decimal {
        guard exponent > 0 else { return exponent == 0 ? 1 : 0 }

        var result: Decimal = 1
        var base = self
        var exp = exponent

        while exp > 0 {
            if exp % 2 == 1 {
                result *= base
            }
            base *= base
            exp /= 2
        }

        return result
    }

    nonisolated var roundedCurrency: Decimal {
        var value = self
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 2, .bankers)
        return rounded
    }
}
