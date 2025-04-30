//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct Alert: View {
    @Injected private var appState: AppState
    @State private(set) var text = ""
    
    var body: some View {
        if appState.system.lastErrorDescription != nil {
            HStack {
                Image(systemName: "info.bubble.fill")
                Text(text)
                    .bold()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            appState.system.lastErrorDescription = nil
                        }
                    }
            }
            .foregroundStyle(.white)
            .padding()
            .tint(.white)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(15)
        }
    }
}
