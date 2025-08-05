//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

extension SDKInteractorReal: MobileAuthRequestDelegate {
    func userClient(_ userClient: UserClient, didReceiveConfirmation confirmation: @escaping (Bool) -> Void, for request: MobileAuthRequest) {
        mobileAuthEntity.message = request.message
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .confirmation
        mobileAuthEntity.confirmation = confirmation
        //TODO: presentConfirmationView in the next PR
    }

}
