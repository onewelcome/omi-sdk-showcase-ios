//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol AuthenticatorRegistrationInteractor {
    func registerAuthenticator(name: String, for profile: String)
    func authenticatorNames(for userId: String) -> [String]
    func unregisteredAuthenticatorNames(for userId: String) -> [String]
}

class AuthenticatorRegistrationInteractorReal: AuthenticatorRegistrationInteractor {
    @ObservedObject var appState: AppState
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    private let userClient = SharedUserClient.instance

    init(appState: AppState) {
        self.appState = appState
    }

    func registerAuthenticator(name: String, for profile: String) {
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == profile }) else {
            fatalError("No user profile for profile `\(profile)`")
        }
        
        guard let authenticator = userClient.authenticators(.nonRegistered, for: userProfile).first(where: { $0.name == name }) else {
            appState.setSystemInfo(string: "No authenticator named `\(name)` unregistered for user `\(profile)`")
            return
        }
        userClient.register(authenticator: authenticator, delegate: self)
    }
    
    func unregisteredAuthenticatorNames(for userId: String) -> [String] {
        return userClient.authenticators(.nonRegistered, for: ProfileProxy(profileId: userId)).map { $0.name }
    }

    
    func authenticatorNames(for userId: String) -> [String] {
        if userId == UserState.stateless.rawValue {
            return [UserState.stateless.rawValue]
        } else {
            return userClient.authenticators(.registered, for: ProfileProxy(profileId: userId)).map { $0.name }
        }
    }
    
    func fetchEnrollment() {
        if isMobileAuthEnrolled {
            appState.system.setEnrollmentState(.mobile)
        }
        if isPushRegistered {
            appState.system.setEnrollmentState(.push)
        }
    }
    
    var isMobileAuthEnrolled: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isMobileAuthEnrolled(for: ProfileProxy(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    var isPushRegistered: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: ProfileProxy(profileId: profileId)) else {
            return false
        }
        
        return true
    }
}

extension AuthenticatorRegistrationInteractorReal: AuthenticatorRegistrationDelegate {

    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCustomAuthFinishRegistrationChallenge challenge: any OneginiSDKiOS.CustomAuthFinishRegistrationChallenge) {
        challenge.sender.respond(with: DummyData.customAuthFinishRegistrationChallenge, to: challenge)
    }

    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didFailToRegister authenticator: any OneginiSDKiOS.Authenticator, for userProfile: any OneginiSDKiOS.UserProfile, error: any Error) {
        appState.setSystemInfo(string: error.localizedDescription)
    }
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didRegister authenticator: any OneginiSDKiOS.Authenticator, for userProfile: any OneginiSDKiOS.UserProfile, info customAuthInfo: (any OneginiSDKiOS.CustomInfo)?) {
        appState.setSystemInfo(string: "Authenticator `\(authenticator.name)` registered successfully.")
    }

}
