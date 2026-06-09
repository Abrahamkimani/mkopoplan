//
//  mkopoplanApp.swift
//  mkopoplan
//

import SwiftUI
import SwiftData

@main
struct mkopoplanApp: App {
    @State private var bootstrapResult: Result<ModelContainerFactory.Bootstrap, Error>? = ModelContainerFactory.load()

    var body: some Scene {
        WindowGroup {
            Group {
                switch bootstrapResult {
                case .success(let bootstrap):
                    MainTabView(persistenceWarning: bootstrap.warningMessage)
                        .modelContainer(bootstrap.container)
                case .failure(let error):
                    PersistenceErrorView(message: error.localizedDescription) {
                        bootstrapResult = ModelContainerFactory.load()
                    }
                case .none:
                    ProgressView("Loading…")
                }
            }
        }
    }
}
