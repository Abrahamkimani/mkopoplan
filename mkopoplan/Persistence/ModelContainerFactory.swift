//
//  ModelContainerFactory.swift
//  mkopoplan
//

import Foundation
import SwiftData

enum PersistenceMode: Equatable {
    case persistent
    case inMemoryFallback
}

enum ModelContainerFactory {
    struct Bootstrap: Equatable {
        let container: ModelContainer
        let mode: PersistenceMode
        let warningMessage: String?

        static func == (lhs: Bootstrap, rhs: Bootstrap) -> Bool {
            lhs.mode == rhs.mode && lhs.warningMessage == rhs.warningMessage
        }
    }

    static func load() -> Result<Bootstrap, Error> {
        let schema = Schema([SavedLoanCalculation.self])

        do {
            let storeURL = try persistentStoreURL()
            let configuration = ModelConfiguration(schema: schema, url: storeURL)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return .success(Bootstrap(container: container, mode: .persistent, warningMessage: nil))
        } catch let persistentError {
            do {
                let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let container = try ModelContainer(for: schema, configurations: [configuration])
                return .success(
                    Bootstrap(
                        container: container,
                        mode: .inMemoryFallback,
                        warningMessage: "Saved calculations won't persist until storage is available. (\(persistentError.localizedDescription))"
                    )
                )
            } catch {
                return .failure(persistentError)
            }
        }
    }

    private static func persistentStoreURL() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        try fileManager.createDirectory(at: appSupport, withIntermediateDirectories: true)
        return appSupport.appendingPathComponent("mkopoplan.store", isDirectory: false)
    }
}
