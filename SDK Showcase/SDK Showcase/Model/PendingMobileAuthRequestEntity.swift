//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class PendingMobileAuthRequestEntity {
    var pendingTransaction: PendingMobileAuthRequest? = nil
    var otp: String? = nil
    var delegate: MobileAuthRequestDelegate? = nil
    var isConfirmed = false
    
    init(pendingTransaction: PendingMobileAuthRequest? = nil, otp: String? = nil, delegate: MobileAuthRequestDelegate? = nil) {
        self.pendingTransaction = pendingTransaction
        self.otp = otp
        self.delegate = delegate
    }
}

//MARK: - Equitable, Hashable
extension PendingMobileAuthRequestEntity: Hashable {
    static func == (lhs: PendingMobileAuthRequestEntity, rhs: PendingMobileAuthRequestEntity) -> Bool {
        lhs.pendingTransaction?.transactionId == rhs.pendingTransaction?.transactionId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pendingTransaction?.transactionId)
    }
}
