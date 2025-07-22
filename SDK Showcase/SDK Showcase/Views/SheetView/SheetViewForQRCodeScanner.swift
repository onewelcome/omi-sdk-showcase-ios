//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForQRCodeScanner: View {
    var body: some View {
        VStack {
            SheetViewDismiss()
            QRCodeScanner()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
