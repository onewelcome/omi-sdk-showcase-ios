//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import OneginiSDKiOS

extension SDKInteractorReal: MobileAuthRequestDelegate {
    func userClient(_ userClient: UserClient, didReceiveConfirmation confirmation: @escaping (Bool) -> Void, for request: MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .confirmation
        mobileAuthEntity.confirmation = confirmation
        
        confirmTransaction(for: mobileAuthEntity, automatically: true)
        appState.system.isProcessing = false
    }
    
    func userClient(_ userClient: any UserClient, didFailToHandleRequest request: any MobileAuthRequest, authenticator: (any Authenticator)?, error: any Error) {
        appState.setSystemInfo(string: error.localizedDescription)
        pushInteractor.updateBadge(nil)
        appState.system.isProcessing = false
    }
}
