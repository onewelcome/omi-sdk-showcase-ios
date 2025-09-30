//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import OneginiSDKiOS

extension SDKInteractorReal: AuthenticationDelegate {
    func userClient(_ userClient: UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: CustomAuthFinishAuthenticationChallenge) {
        challenge.sender.respond(with: DummyData.customAuthFinishRegistrationChallenge, to: challenge)
        appState.system.isProcessing = false
    }
    
    func userClient(_ userClient: UserClient, didAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, info customAuthInfo: CustomInfo?) {
        appState.unsetSystemInfo()
        appState.system.setUserState(.authenticated(userProfile.profileId))
        appState.system.setPinPadState(.hidden)
        fetchEnrollment()
        appState.system.isProcessing = false
    }
    
    func userClient(_ userClient: UserClient, didFailToAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, error: Error) {
        appState.setSystemInfo(string: "Authentication failed")
        if SDKError(error) == .accountDeregistered {
            appState.remove(profileId: userProfile.profileId)
            pinPadInteractor.showPinPad(for: .hidden)
        }
        appState.system.isProcessing = false
    }
}
