//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import OneginiSDKiOS

extension SDKInteractorReal: RegistrationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        if let error = challenge.error {
            pinPadInteractor.setCreatePinChallenge(challenge)
            pinPadInteractor.showError(error)
            return
        }
        switch appState.system.pinPadState {
        case .changing:
            appState.system.setPinPadState(.hidden)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self else { return }
                self.pinPadInteractor.setCreatePinChallenge(challenge)
                self.pinPadInteractor.showPinPad(for: .creating)
            }
        default:
            browserInteractor.didReceiveCreatePinChallenge(challenge)
        }
    }

    func userClient(_ userClient: any UserClient, didRegisterUser profile: any UserProfile, with identityProvider: any IdentityProvider, info: (any CustomInfo)?) {
        browserInteractor.didRegisterUser(profileId: profile.profileId)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBrowserRegistrationChallenge challenge: any BrowserRegistrationChallenge) {
        browserInteractor.didReceiveBrowserRegistrationChallenge(challenge)
    }
    
    func userClient(_ userClient: any UserClient, didFailToRegisterUserWith identityProvider: any IdentityProvider, error: any Error) {
        browserInteractor.didFailToRegisterUser(with: error)
    }
}
