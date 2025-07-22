//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
//import SwiftUI
//import OneginiSDKiOS

//MARK: - Protocol
protocol QRScannerInteractor {
    func scan()
    func cancel()
}

//MARK: - Real methods
class QRScannerInteractorReal: QRScannerInteractor {
    @Injected var appState: AppState
    
    func scan() {
        // TODO: Show QR scaner here
        appState.system.shouldShowQRScanner = true
    }
    
    func cancel() {
        appState.system.shouldShowQRScanner = false
    }
}
