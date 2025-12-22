//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol AuthenticatorRegistrationInteractor {
    func registerAuthenticator(name: String, for profile: String)
    func authenticatorNames(for userId: String) -> [String]
    func unregisteredAuthenticatorNames(for userId: String) -> [String]
}

class AuthenticatorRegistrationInteractorReal: AuthenticatorRegistrationInteractor {
    @ObservedObject var app: ShowcaseApp
    private let userClient = SharedUserClient.instance

    init(app: ShowcaseApp) {
        self.app = app
    }

    func registerAuthenticator(name: String, for profile: String) {
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == profile }) else {
            fatalError("No user profile for profile `\(profile)`")
        }
        
        guard let authenticator = userClient.authenticators(.nonRegistered, for: userProfile).first(where: { $0.name == name }) else {
            app.setSystemInfo(string: "No authenticator named `\(name)` unregistered for user `\(profile)`")
            return
        }
        userClient.register(authenticator: authenticator, delegate: self)
    }
    
    func unregisteredAuthenticatorNames(for userId: String) -> [String] {
        return userClient.authenticators(.nonRegistered, for: UserProfileImplementation(profileId: userId)).map { $0.name }
    }

    
    func authenticatorNames(for userId: String) -> [String] {
        if userId == UserState.stateless.rawValue {
            return [UserState.stateless.rawValue]
        } else {
            return userClient.authenticators(.registered, for: UserProfileImplementation(profileId: userId)).map { $0.name }
        }
    }
}

extension AuthenticatorRegistrationInteractorReal: AuthenticatorRegistrationDelegate {
    
    func userClient(_ userClient: any UserClient, didReceivePinChallenge challenge: any PinChallenge) {
        pinPadInteractor.setPinChallenge(challenge)
        if let _ = challenge.error {
            app.setSystemInfo(string: "Wrong previous PIN, please try again (\(challenge.remainingFailureCount))")
            return
        }
        app.system.isProcessing = false
        pinPadInteractor.showPinPad(for: .biometricFallback)
    }
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCustomAuthFinishRegistrationChallenge challenge: any OneginiSDKiOS.CustomAuthFinishRegistrationChallenge) {
        challenge.sender.respond(with: DummyData.customAuthFinishRegistrationChallenge, to: challenge)
    }
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didFailToRegister authenticator: OneginiSDKiOS.Authenticator, for userProfile: any OneginiSDKiOS.UserProfile, error: any Error) {
        app.setSystemInfo(string: error.localizedDescription)
    }
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didRegister authenticator: OneginiSDKiOS.Authenticator, for userProfile: any OneginiSDKiOS.UserProfile, info customAuthInfo: (any OneginiSDKiOS.CustomInfo)?) {
        app.setSystemInfo(string: "Authenticator `\(authenticator.name)` registered successfully.")
    }
}

private extension AuthenticatorRegistrationInteractorReal {
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var isPushRegistered: Bool {
        guard let profileId = app.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: UserProfileImplementation(profileId: profileId)) else {
            return false
        }
        
        return true
    }
}
