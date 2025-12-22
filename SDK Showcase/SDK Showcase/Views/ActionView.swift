//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct ActionView: View {
    @Binding var action: Action
    @State var position: Double = 0.0
    
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
                    HStack {
                        Text("\(position, specifier: "%.0f")")
                        Slider(value: $position, in: 0...100, step: 1.0)
                            .onChange(of: position) { $action.wrappedValue.providedValue = $1 }
                            .onAppear { $position.wrappedValue = action.defaultValue as? Double ?? 0 }
                    }
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
