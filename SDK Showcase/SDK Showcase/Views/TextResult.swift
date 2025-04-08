//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct TextResult: View {
    var result: String
    var body: some View {
        Text(result)
            .font(.system(size: 12))
            .monospaced()
    }
}
