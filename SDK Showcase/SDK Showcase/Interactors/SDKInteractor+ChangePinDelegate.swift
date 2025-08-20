//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import OneginiSDKiOS

extension SDKInteractorReal: ChangePinDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceivePinChallenge challenge: any OneginiSDKiOS.PinChallenge) {
        pinPadInteractor.setPinChallenge(challenge)
        if let _ = challenge.error {
            appState.setSystemInfo(string: "Wrong previous PIN, please try again (\(challenge.remainingFailureCount))")
            return
        }
        appState.system.isProcessing = false
        pinPadInteractor.showPinPad(for: .changing)
    }
    
    func userClient(_ userClient: any UserClient, didChangePinForUser profile: any UserProfile) {
        appState.system.isProcessing = false
        pinPadInteractor.didChangePinForUser()
    }

    func userClient(_ userClient: any UserClient, didFailToChangePinForUser profile: any UserProfile, error: any Error) {
        appState.system.isProcessing = false
        appState.setSystemInfo(string: error.localizedDescription)
    }
}
