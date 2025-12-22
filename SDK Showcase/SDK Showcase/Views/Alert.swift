//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct Alert: View {
    private var visibilityTime: Double {
        let minVisibilityTime = 3.0
        let maxVisibilityTime = 10.0
        if text.count < 50 {
            return minVisibilityTime
        } else {
            return min(Double(text.count/15), maxVisibilityTime)
        }
    }

    @Injected private var app: ShowcaseApp
    @State private(set) var text = ""
    
    var body: some View {
        HStack {
            Image(systemName: "info.bubble.fill")
            Text(text)
                .bold()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + visibilityTime) {
                        app.unsetSystemInfo()
                    }
                }
        }
        .foregroundStyle(.white)
        .padding()
        .tint(.white)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(15)
        .onTapGesture {
            app.unsetSystemInfo()
        }
    }
}
