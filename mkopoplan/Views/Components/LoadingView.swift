//
//  LoadingView.swift
//  mkopoplan
//

import SwiftUI

struct LoadingView: View {
    var message: String = "Calculating…"

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
