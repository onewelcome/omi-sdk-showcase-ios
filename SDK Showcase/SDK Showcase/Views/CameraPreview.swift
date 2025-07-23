//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import UIKit
import AVFoundation

class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    init() {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
}
