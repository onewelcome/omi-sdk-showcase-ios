//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForQRScanner: View {
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text("Scan OTP QR code")
                .font(.subheadline)
            QRScannerPresenter()
                .setQRCodeHandler { code in
                    qrScannerInteractor.handleCode(code)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}

private extension SheetViewForQRScanner {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
}
