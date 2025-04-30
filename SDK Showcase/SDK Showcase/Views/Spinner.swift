//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct Spinner: View {
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
    }
}
