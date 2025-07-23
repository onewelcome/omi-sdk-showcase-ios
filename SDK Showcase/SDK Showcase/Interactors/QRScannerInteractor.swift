//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

//MARK: - Protocol
protocol QRScannerInteractor {
    func scan()
    func cancel()
    func handleCode(_ code: String)
}

//MARK: - Real methods
class QRScannerInteractorReal: QRScannerInteractor {
    @Injected var appState: AppState
    
    func scan() {
        appState.system.shouldShowQRScanner = true
    }
    
    func cancel() {
        appState.system.shouldShowQRScanner = false
    }
    
    func handleCode(_ code: String) {
        appState.system.shouldShowQRScanner = false
        sdkInteractor.handleOtp(code)
    }
}

private extension QRScannerInteractorReal {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
}
