//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct ActionView: View {
    @Binding var action: Action
    
    var body: some View {
        DisclosureGroup() {
            if let description = action.description {
                Text(description)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            HStack {
                if (action.providedValue is Bool || action.defaultValue is Bool) {
                    Toggle(action.name, isOn: Binding(isNotNil: $action.providedValue, defaultValue: action.defaultValue))
                } else {
                    TextField(text: Binding(isNotNil: $action.providedValue, defaultValue: nil)) {
                        Text(action.defaultValue as? String ?? "")
                    }
                }
            }
        } label: {
            HStack {
                Text(action.name)
            }
        }
    }
}
