//
//  MainTabView.swift
//  mkopoplan
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var persistenceWarning: String?

    @AppStorage(AppearanceSettings.storageKey) private var appearanceRaw = AppAppearance.system.rawValue
    @State private var calculatorViewModel = LoanCalculatorViewModel()
    @State private var comparisonViewModel = LoanComparisonViewModel()
    @State private var selectedTab = AppTab.calculator.rawValue

    private var colorScheme: ColorScheme? {
        AppAppearance(rawValue: appearanceRaw)?.colorScheme
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                LoanCalculatorView(viewModel: calculatorViewModel)
            }
            .tabItem {
                Label("Calculator", systemImage: "plus.forwardslash.minus")
            }
            .tag(AppTab.calculator.rawValue)

            NavigationStack {
                LoanComparisonView(viewModel: comparisonViewModel)
            }
            .tabItem {
                Label("Compare", systemImage: "arrow.left.arrow.right")
            }
            .tag(AppTab.compare.rawValue)

            NavigationStack {
                HistoryView(
                    calculatorViewModel: calculatorViewModel,
                    selectedTab: $selectedTab
                )
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(AppTab.history.rawValue)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(AppTab.settings.rawValue)
        }
        .tint(AppTheme.accent)
        .preferredColorScheme(colorScheme)
        .safeAreaInset(edge: .top, spacing: 0) {
            if let persistenceWarning {
                PersistenceDegradedBanner(message: persistenceWarning)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
        }
        .toolbar(.visible, for: .tabBar)
        .onChange(of: selectedTab) { _, _ in
            KeyboardDismiss.dismiss()
        }
    }
}

private enum AppTab: Int {
    case calculator
    case compare
    case history
    case settings
}

#Preview {
    MainTabView()
        .modelContainer(for: SavedLoanCalculation.self, inMemory: true)
}
