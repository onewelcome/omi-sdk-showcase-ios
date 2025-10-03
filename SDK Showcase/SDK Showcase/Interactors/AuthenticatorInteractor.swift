//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol AuthenticatorInteractor {
    func authenticateUser(profileName: String, optionName: String)
    func loginWithOTP()
    func fetchIdentityProviders() -> [IdentityProvider]
}

class AuthenticatorInteractorReal: AuthenticatorInteractor {
    private let userClient = SharedUserClient.instance
    @ObservedObject var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }
    
    func loginWithOTP() {
        qrScannerInteractor.scan(to: self)
    }
    
    func fetchIdentityProviders() -> [any IdentityProvider] {
        let providers = userClient.identityProviders
        return providers
    }
    
    func authenticateUser(profileName: String, optionName: String) {
        guard optionName != UserState.stateless.rawValue else {
            appState.setSystemInfo(string: "Stateless user is authenticated automatically.")
            return
        }
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == profileName }) else {
            fatalError("No user profile for profile `\(profileName)`")
        }

        guard let authenticator = userClient.authenticators(.registered, for: userProfile).first(where: { $0.name == optionName }) else {
            appState.setSystemInfo(string: "No authenticator named `\(optionName)` registered for user `\(profileName)`")
            return
        }
        appState.system.isProcessing = true
        userClient.authenticateUserWith(profile: userProfile, authenticator: authenticator, delegate: self)
    }
}

extension AuthenticatorInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        appState.system.setScannerState(.showForOTP)
    }

    func didCancelScanning() {
        appState.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        appState.system.setScannerState(.hidden)
        mobileAuthRequestInteractor.handleOtp(code)
    }
}

extension AuthenticatorInteractorReal: AuthenticationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceivePinChallenge challenge: any OneginiSDKiOS.PinChallenge) {
        appState.unsetSystemInfo()
        appState.system.isProcessing = false
        pinPadInteractor.setPinChallenge(challenge)

        guard let error = challenge.error else {
            pinPadInteractor.showPinPad(for: .authenticating)
            return
        }
        
        switch SDKError(error) {
        case .biometricAuthenticationFallback:
            pinPadInteractor.showPinPad(for: .biometricFallback)
        default:
            appState.setSystemInfo(string: error.localizedDescription)
        }
    }
    
    func userClient(_ userClient: UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: CustomAuthFinishAuthenticationChallenge) {
        challenge.sender.respond(with: DummyData.customAuthFinishRegistrationChallenge, to: challenge)
        appState.system.isProcessing = false
    }
    
    func userClient(_ userClient: UserClient, didAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, info customAuthInfo: CustomInfo?) {
        appState.unsetSystemInfo()
        appState.system.setUserState(.authenticated(userProfile.profileId))
        appState.system.setPinPadState(.hidden)
        mobileAuthRequestInteractor.fetchEnrollment()
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

private extension AuthenticatorInteractorReal {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var mobileAuthRequestInteractor: MobileAuthRequestInteractor {
        @Injected var interactors: Interactors
        return interactors.mobileAuthRequestInteractor
    }
}
