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
                }
                else if (action.providedValue is Double || action.defaultValue is Double) {
                    Slider(value: Binding(isNotNil: $action.providedValue, defaultValue: action.defaultValue), in: 0...100, step: 1.0)
                    Text("\((action.providedValue ?? action.defaultValue) as! Double, specifier: "%.0f")")
                }
                else {
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
