//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import Foundation

class QRCodeViewModel: ObservableObject {
    func onFoundQrCode(_ code: String) {
        qrScannerInteractor.handleCode(code)
    }
}

private extension QRCodeViewModel {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
}
