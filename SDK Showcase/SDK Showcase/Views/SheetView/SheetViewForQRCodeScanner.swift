//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForQRScanner: View {
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text(errorMessage ?? "Scan OTP QR code")
                .multilineTextAlignment(.leading)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            QRScannerPresenter().setHandler { result in
                switch result {
                case .failure(let error):
                    guard case QRScannerPresenter.ScannerError.noCameraAccess = error else {
                        errorMessage = "Unknown error occurred."
                        return
                    }
                    errorMessage = "Camera access denied. Please go to System Settings and grand an access."
                case .success(let qrCode):
                    qrScannerInteractor.handleCode(qrCode)
                }
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
