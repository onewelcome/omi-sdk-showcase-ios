//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class MobileAuthRequestQueue {
    private var list = [PendingMobileAuthRequestEntity]()
    private var userClient: UserClient {
        return SharedUserClient.instance
    }
    
    func enqueue(_ mobileAuthRequest: PendingMobileAuthRequestEntity) {
        if list.isEmpty {
            handleMobileAuthRequest(mobileAuthRequest)
        }
        list.append(mobileAuthRequest)
    }

    func dequeue() {
        if !list.isEmpty {
            list.removeFirst()
            if let firstElement = list.first {
                handleMobileAuthRequest(firstElement)
            }
        }
    }

    func handleMobileAuthRequest(_ mobileAuthRequest: PendingMobileAuthRequestEntity) {
        guard let delegate = mobileAuthRequest.delegate else { return }
        
        if let pendingTransaction = mobileAuthRequest.pendingTransaction {
            userClient.handlePendingMobileAuthRequest(pendingTransaction, delegate: delegate)
        } else if let otp = mobileAuthRequest.otp {
            userClient.handleOTPMobileAuthRequest(otp: otp, delegate: delegate)
        }
    }
}
