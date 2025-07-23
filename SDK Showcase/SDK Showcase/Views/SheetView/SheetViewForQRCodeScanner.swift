//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI
struct SheetViewForQRCodeScanner: View {
    @ObservedObject var viewModel = ScannerViewModel() // TODO: rename for QRCodeScannerViewModel
    
    var body: some View {
        VStack {
            SheetViewDismiss()
            Text("Keep scanning for QR-codes")
                                    .font(.subheadline)
            Text(self.viewModel.lastQrCode)
            QrCodeScannerView()
            .found(r: self.viewModel.onFoundQrCode)
            .torchLight(isOn: self.viewModel.torchIsOn)
            .interval(delay: self.viewModel.scanInterval)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}


class ScannerViewModel: ObservableObject {
    
    /// Defines how often we are going to try looking for a new QR-code in the camera feed.
    let scanInterval: Double = 1.0
    
    @Published var torchIsOn: Bool = false
    @Published var lastQrCode: String = "Qr-code goes here"
    
    
    func onFoundQrCode(_ code: String) {
        self.lastQrCode = code
    }
}
