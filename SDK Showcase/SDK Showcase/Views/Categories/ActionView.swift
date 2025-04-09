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
                if action.type == .string {
                    TextField(text: $action.value) {
                        Text(action.defaultValue)
                    }
                } else {
                    Toggle(action.name, isOn: $action.boolValue)
                }
            }
        } label: {
            HStack {
                Text(action.name)
            }
        }
    }
}
