//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct Spinner: View {
    @ObservedObject private var app: ShowcaseApp = {
        @Injected var app: ShowcaseApp
        return app
    }()
    @State private var timer: Timer?
    var body: some View {
        ProgressView() {
            Text("Loading...")
                .bold()
                .foregroundStyle(.white)
        }
        .padding()
        .tint(.white)
        .background(Color.gray.opacity(0.8))
        .cornerRadius(15)
        .onAppear {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
                timer?.invalidate()
                timer = nil
                app.setSystemInfo(string: "The operation takes longer than expected, please check your internet connection or try again later.")
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}
