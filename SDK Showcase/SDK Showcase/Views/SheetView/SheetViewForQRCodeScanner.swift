//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI
//ScannerView
struct SheetViewForCGImageView: View {
    @ObservedObject var viewModel = QRCodeViewModel()
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text("Keep scanning for QR-codes")
                                    .font(.subheadline)
            Text(viewModel.lastCode ?? "No code found") // TODO: temporary
            QRViewPresenter()
                .setQRCodeHandler(viewModel.onFoundQrCode)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
