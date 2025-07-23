//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForQRScanner: View {
    @ObservedObject var viewModel = QRCodeViewModel()
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text("Scan OTP QR code")
                .font(.subheadline)
            QRScannerPresenter()
                .setQRCodeHandler(viewModel.onFoundQrCode)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
