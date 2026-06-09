//
//  KeyboardDismiss.swift
//  mkopoplan
//

import SwiftUI

enum KeyboardDismiss {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

private struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        KeyboardDismiss.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
    }
}

extension View {
    /// Adds a keyboard Done button and interactive scroll-to-dismiss.
    func dismissKeyboardOnInteraction() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
