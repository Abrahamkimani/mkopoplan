//
//  Item.swift
//  mkopoplan
//
//  Created by Abraham Kimani on 09/06/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
