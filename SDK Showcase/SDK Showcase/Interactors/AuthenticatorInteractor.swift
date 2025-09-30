//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

protocol AuthenticatorInteractor {
    func loginWithOTP()
}

class AuthenticatorInteractorReal: AuthenticatorInteractor {
    @ObservedObject var appState: AppState
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func loginWithOTP() {
        qrScannerInteractor.scan(to: self)
    }
}

extension AuthenticatorInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        appState.system.setScannerState(.showForOTP)
    }

    func didCancelScanning() {
        appState.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        appState.system.setScannerState(.hidden)
        sdkInteractor.handleOtp(code)
    }
}
