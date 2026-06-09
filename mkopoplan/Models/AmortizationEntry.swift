//
//  AmortizationEntry.swift
//  mkopoplan
//

import Foundation

struct AmortizationEntry: Identifiable, Equatable, Sendable {
    let id: Int
    let paymentNumber: Int
    let emi: Decimal
    let interestPortion: Decimal
    let principalPortion: Decimal
    let remainingBalance: Decimal
}
