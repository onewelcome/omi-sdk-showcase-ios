//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol AuthenticatorInteractor {
    var openIDtoken: String? { get }
    var accessToken: String? { get }

    func authenticateUser(profileName: String, optionName: String)
    func implicitlyAuthenticate(profileName: String)
    func logout(optionName: String)
    func loginWithOTP()
    func fetchIdentityProviders() -> [IdentityProvider]
    func sso()
    func showToken(_ token: String)
}

class AuthenticatorInteractorReal: AuthenticatorInteractor {
    private let userClient = SharedUserClient.instance
    @ObservedObject var app: ShowcaseApp

    init(app: ShowcaseApp) {
        self.app = app
    }
    
    var openIDtoken: String? {
        return userClient.idToken
    }
    
    var accessToken: String? {
        return userClient.accessToken
    }
    
    func showToken(_ token: String) {
        switch Token(rawValue: token) {
        case .access:
            app.setSystemInfo(string: accessToken?.truncated() ?? "")
        case .openID:
            app.setSystemInfo(string: openIDtoken?.truncated() ?? "")
        default:
            break
        }
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
            app.setSystemInfo(string: "Stateless user is authenticated automatically.")
            return
        }
        guard let userProfile = userClient.userProfiles.first(where: { $0.profileId == profileName }) else {
            fatalError("No user profile for profile `\(profileName)`")
        }

        guard let authenticator = userClient.authenticators(.registered, for: userProfile).first(where: { $0.name == optionName }) else {
            app.setSystemInfo(string: "No authenticator named `\(optionName)` registered for user `\(profileName)`")
            return
        }
        app.system.isProcessing = true
        
        let loginAction = { [weak self] in
            guard let self else { return }
            userClient.authenticateUserWith(profile: userProfile, authenticator: authenticator, delegate: self)
        }
        
        performLoginAction(loginAction)
    }
    
    func implicitlyAuthenticate(profileName: String) {
        guard let userProfile = userClient.userProfiles.first(where: { $0.profileId == profileName }) else {
            fatalError("No user profile for profile `\(profileName)`")
        }
        /// First check if the user is already authenticated implicitely
        if let implicitUser = userClient.implicitlyAuthenticatedUserProfile, implicitUser.isEqual(to: userProfile) {
            app.setSystemInfo(string: "Profile \(userProfile) has already been logged in implicitly.")
        } else {
            let loginAction = { [weak self] in
                /// If it is not proceed with the authentication
                self?.userClient.implicitlyAuthenticate(user: userProfile, with: nil) { [weak self] error in
                    guard let self else { return }
                    if let error {
                        app.system.setUserState(.unauthenticated)
                        app.setSystemInfo(string: error.localizedDescription)
                    } else {
                        app.system.setUserState(.implicit)
                        app.setSystemInfo(string: "Profile \(userProfile) has been implicitly logged in.")
                    }
                }
            }

            performLoginAction(loginAction)
        }
    }
    
    func logout(optionName: String) {
        userClient.logoutUser { [self] profile, error in
            if profile != nil {
                app.system.setUserState(.unauthenticated)
                app.setSystemInfo(string: "Profile \(optionName) has been logged out.")
            } else {
                app.setSystemInfo(string: "Logout failed. The profile is not authenticated most likely.")
            }
        }
    }
    
    func sso() {
        guard userClient.accessToken != nil, let dashboardUrl = URL(string: SDKConfigModel.defaultPersonalDashboardURL) else {
            app.setSystemInfo(string: "You must be authenticated first.")
            return
        }

        userClient.appToWebSingleSignOn(with: dashboardUrl) { [self] url, token, error in
            guard let url, error == nil else {
                app.setSystemInfo(string: error?.localizedDescription ?? "An unknown error occured.")
                return
            }
            app.system.setUserState(.sso(url.absoluteString))
        }
    }
}

extension AuthenticatorInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        app.system.setScannerState(.showForOTP)
    }

    func didCancelScanning() {
        app.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        app.system.setScannerState(.hidden)
        mobileAuthRequestInteractor.handleOtp(code)
    }
}

extension AuthenticatorInteractorReal: AuthenticationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceivePinChallenge challenge: any OneginiSDKiOS.PinChallenge) {
        app.unsetSystemInfo()
        app.system.isProcessing = false
        pinPadInteractor.setPinChallenge(challenge)

        guard let error = challenge.error else {
            pinPadInteractor.showPinPad(for: .authenticating)
            return
        }
        
        switch SDKError(error) {
        case .biometricAuthenticationFallback:
            pinPadInteractor.showPinPad(for: .biometricFallback)
        case .authenticationFailed:
            app.setSystemInfo(string: "Wrong PIN, please try again (\(challenge.remainingFailureCount))")
        default:
            app.setSystemInfo(string: error.localizedDescription)
        }
    }
    
    func userClient(_ userClient: UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: CustomAuthFinishAuthenticationChallenge) {
        challenge.sender.respond(with: DummyData.customAuthFinishRegistrationChallenge, to: challenge)
        app.system.isProcessing = false
    }
    
    func userClient(_ userClient: UserClient, didAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, info customAuthInfo: CustomInfo?) {
        app.unsetSystemInfo()
        app.system.setUserState(.authenticated(userProfile.profileId))
        app.system.setPinPadState(.hidden)
        mobileAuthRequestInteractor.fetchEnrollment()
        app.system.isProcessing = false
    }
    
    func userClient(_ userClient: UserClient, didFailToAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, error: Error) {
        if SDKError(error) == .accountDeregistered {
            app.remove(profileId: userProfile.profileId)
            pinPadInteractor.showPinPad(for: .hidden)
            app.setSystemInfo(string: "Too many wrong attempts. Profile has been deregistered.")
        } else {
            app.setSystemInfo(string: "Authentication failed")
        }
        app.system.isProcessing = false
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
    
    func performLoginAction(_ loginAction: @escaping () -> ()?) {
        /// Logout previously authenticated user if any
        if userClient.authenticatedUserProfile != nil || userClient.implicitlyAuthenticatedUserProfile != nil {
            userClient.logoutUser { user, error in
                loginAction()
            }
        } else {
            loginAction()
        }
    }
}
