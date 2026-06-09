//
//  SettingsView.swift
//  mkopoplan
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(AppearanceSettings.storageKey) private var appearanceRaw = AppAppearance.system.rawValue

    private var appearance: Binding<AppAppearance> {
        Binding(
            get: { AppAppearance(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: appearance) {
                    ForEach(AppAppearance.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("App theme")
                .accessibilityHint("Choose light, dark, or follow system settings")
            } header: {
                Text("Appearance")
            }

            Section {
                LabeledContent("App") {
                    Text("Mkopoplan")
                }
                LabeledContent("Version") {
                    Text(Bundle.main.appVersion)
                }
                LabeledContent("Build") {
                    Text(Bundle.main.buildNumber)
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
    }
}
