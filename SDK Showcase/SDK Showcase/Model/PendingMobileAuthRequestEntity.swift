//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class PendingMobileAuthRequestEntity {
    var pendingTransaction: PendingMobileAuthRequest? = nil
    var otp: String? = nil
    var delegate: MobileAuthRequestDelegate? = nil
    
    init(pendingTransaction: PendingMobileAuthRequest? = nil, otp: String? = nil, delegate: MobileAuthRequestDelegate? = nil) {
        self.pendingTransaction = pendingTransaction
        self.otp = otp
        self.delegate = delegate
    }
}
