//
//  AppearanceSettings.swift
//  mkopoplan
//

import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppearanceSettings {
    static let storageKey = "selectedAppearance"

    static var current: AppAppearance {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? AppAppearance.system.rawValue
        return AppAppearance(rawValue: raw) ?? .system
    }
}
