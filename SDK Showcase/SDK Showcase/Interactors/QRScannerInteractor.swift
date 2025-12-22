//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

//MARK: - Protocol
protocol QRScannerInteractor {
    func scan(to: QRScannerDelegate)
    func cancelScanning()
    func scanned(code: String)
}

protocol QRScannerDelegate {
    func didStartScanning()
    func didCancelScanning()
    func didFinishScanning(code: String)
}

//MARK: - Real methods
class QRScannerInteractorReal: QRScannerInteractor {
    var delegate: QRScannerDelegate?
    
    func scan(to receiver: QRScannerDelegate) {
        delegate = receiver
        delegate?.didStartScanning()
    }
    
    func cancelScanning() {
        delegate?.didCancelScanning()
    }
    
    func scanned(code: String) {
        delegate?.didFinishScanning(code: code)
    }
}
