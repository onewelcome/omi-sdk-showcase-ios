//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct ActionView: View {
    @Binding var action: Action
    
    var body: some View {
        DisclosureGroup() {
            Text(action.description)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            HStack {
                if action.valueType == .string {
                    TextField(text: binding(for: action.providedValue as? String)) {
                        Text(action.defaultValue as? String ?? "")
                    }
                } else {
                    Toggle(action.name, isOn: binding(for: action.providedValue as? Bool))
                }
            }
        } label: {
            HStack {
                Text(action.name)
            }
        }
    }
}

private extension ActionView {
    
    func binding<T>(for value: T?) -> Binding<T> {
        return .init(
            get: {
                switch action.valueType {
                case .string:
                    return value ?? "" as! T
                case .boolean:
                    return value ?? false as! T
                }
            },
            set: {
                action.providedValue = $0
            }
        )
    }
}
