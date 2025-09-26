//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import OneginiSDKiOS

extension SDKInteractorReal: AuthenticationDelegate {
    func userClient(_ userClient: UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: CustomAuthFinishAuthenticationChallenge) {
        challenge.sender.respond(with: AuthenticatorRegistrationInteractorReal.dummyRespondData, to: challenge)
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
        if (error as NSError).code == 9003 {
            // User account deregistered (too many wrong PIN attempts)
            appState.registeredUsers.remove(AppState.UserData(userId: userProfile.profileId, authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: userProfile.profileId)))
            pinPadInteractor.showPinPad(for: .hidden)
        }
        appState.system.isProcessing = false
    }
}
