//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI
import UIKit
import AVFoundation

struct QRScannerPresenter: UIViewRepresentable {
    
    private var supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.qr]
    typealias UIViewType = CameraPreview
    
    private var session = AVCaptureSession()
    private let delegate = QrCodeCameraDelegate()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    func setQRCodeHandler(_ handler: @escaping (String) -> Void) -> QRScannerPresenter {
        delegate.onResult = handler
        return self
    }
    
    func setupCamera(_ uiView: CameraPreview) {
        if let backCamera = AVCaptureDevice.default(for: .video) {
            if let input = try? AVCaptureDeviceInput(device: backCamera) {
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(metadataOutput) {
                    session.addOutput(metadataOutput)
                    
                    metadataOutput.metadataObjectTypes = supportedBarcodeTypes
                    metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                }
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                
                uiView.backgroundColor = UIColor.gray
                previewLayer.videoGravity = .resizeAspectFill
                uiView.layer.addSublayer(previewLayer)
                uiView.previewLayer = previewLayer
                
                startSession()
            }
        }
    }
    
    func startSession() {
        guard !session.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak session] in
            session?.startRunning()
        }
    }
    
    func stopSession() {
        guard session.isRunning else { return }
        
        session.stopRunning()
    }
    
    func makeUIView(context: UIViewRepresentableContext<QRScannerPresenter>) -> QRScannerPresenter.UIViewType {
        let cameraView = CameraPreview()
        checkCameraAuthorizationStatus(cameraView)
        return cameraView
    }
    
    private func checkCameraAuthorizationStatus(_ uiView: CameraPreview) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            setupCamera(uiView)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        self.setupCamera(uiView)
                    }
                }
            }
        }
    }
    
    func updateUIView(_ uiView: CameraPreview, context: UIViewRepresentableContext<QRScannerPresenter>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}

class QrCodeCameraDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    private let scanInterval: Double = 1.0
    private var lastTime = Date(timeIntervalSince1970: 0)
    var onResult: (String) -> Void = { _  in }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            handleQRCodeString(stringValue)
        }
    }
    
    func handleQRCodeString(_ stringValue: String) {
        let now = Date()
        if now.timeIntervalSince(lastTime) >= scanInterval {
            lastTime = now
            self.onResult(stringValue)
        }
    }
}
