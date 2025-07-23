//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import Foundation

class QRCodeViewModel: ObservableObject {
    // TODO; remove if not needed anymore
    @Published private(set) var lastCode: String?
    
    func onFoundQrCode(_ code: String) {
        lastCode = code
        qrScannerInteractor.handleCode(code)
    }
}

private extension QRCodeViewModel {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
}
