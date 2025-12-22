//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForQRScanner: View {
    @State private var errorMessage: String?
    @ObservedObject private var system: ShowcaseApp.System = {
        @Injected var app: ShowcaseApp
        return app.system
    }()
    
    var title: String {
        switch system.scannerState {
        case .showForOTP:
            "Scan OTP QR code to authenticate"
        case .showForRegistration:
            "Scan QR code to register"
        default:
            errorMessage ?? ""
        }
    }
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text(title)
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
                    qrScannerInteractor.scanned(code: qrCode)
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
