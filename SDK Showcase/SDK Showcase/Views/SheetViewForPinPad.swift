
//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForPinPad: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                    system.isError = true
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            PinPad() {
                dismiss()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
