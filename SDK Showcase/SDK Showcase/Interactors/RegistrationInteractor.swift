//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol RegistrationInteractor {
    var registerUrl: String { get set }
    var userAuthenticatorOptionNames: [String] { get }
    var numberOfRegisteredUsers: Int { get }

    func fetchUserProfiles()
    func setBrowserChallenge(_ challenge: BrowserRegistrationChallenge)
    func setCustomChallenge(_ challenge: CustomRegistrationChallenge)
    func setStateless(_ stateless: Bool)
    func register(with provider: String, stateless: Bool)
    func register(with idp: String)
    func deregister(optionName: String)
    func cancelRegistration()
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
}

//MARK: - Real methods
class RegistrationInteractorReal: RegistrationInteractor {
    @ObservedObject var app: ShowcaseApp
    private let userClient = SharedUserClient.instance
    private var browserChallenge: BrowserRegistrationChallenge?
    private var customChallenge: CustomRegistrationChallenge?
    private var stateless = false
    var registerUrl: String

    init(registerUrl: String = "", app: ShowcaseApp) {
        self.registerUrl = registerUrl
        self.app = app
    }
    
    var userAuthenticatorOptionNames: [String] {
        return app.registeredUsers.map { $0.userId }
    }
    
    var numberOfRegisteredUsers: Int {
        return app.registeredUsers.filter { $0.isStateless == false }.map { $0.userId }.count
    }

    func setBrowserChallenge(_ challenge: any BrowserRegistrationChallenge) {
        self.registerUrl = challenge.url.absoluteString
        self.browserChallenge = challenge
    }
    
    func setCustomChallenge(_ challenge: any CustomRegistrationChallenge) {
        self.customChallenge = challenge
    }
    
    func setStateless(_ stateless: Bool) {
        self.stateless = stateless
    }
    
    func register(with idp: String) {
        guard app.system.isSDKInitialized else {
            app.setSystemInfo(string: "SDK not initialized")
            return
        }
        register(with: idp, stateless: stateless)
    }
    
    func deregister(optionName: String) {
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == optionName }) else {
            if optionName == UserState.stateless.rawValue {
                app.setSystemInfo(string: "Deregistration cannot be performed for the stateless user.")
            } else {
                app.setSystemInfo(string: "Deregistration failed. The profile has been already unregistered.")
            }
            return
        }
        userClient.deregister(user: userProfile) { [self] error in
            if error != nil {
                app.setSystemInfo(string: "Deregistration failed. The profile has not been found.")
            } else {
                app.remove(profileId: userProfile.profileId)
                app.setSystemInfo(string: "Profile \(optionName) has been deregister.")
            }
        }
    }
    
    func fetchUserProfiles() {
        app.resetRegisteredUsers()
        userClient.userProfiles
            .map { ShowcaseApp.UserData(userId: $0.profileId, authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: $0.profileId)) }
            .forEach { app.addRegisteredUser($0) }
    }
    
    func register(with provider: String, stateless: Bool) {
        app.system.isProcessing = true
        let scopes = ["read", "openid", "email"]
        let provider = userClient.identityProviders.first(where: { $0.name == provider })
        if stateless {
            userClient.registerStatelessUserWith(identityProvider: provider, scopes: scopes, delegate: self)
        } else {
            userClient.registerUserWith(identityProvider: provider, scopes: scopes, delegate: self)
        }
    }
    
    func cancelRegistration() {
        if let browserChallenge {
            browserChallenge.sender.cancel(browserChallenge)
        } else if let customChallenge {
            customChallenge.sender.cancel(customChallenge, withUnderlyingError: nil)
        }
        switch app.system.userState {
        case .sso:
            if let userId = userClient.authenticatedUserProfile?.profileId {
                app.system.setUserState(.authenticated(userId))
            } else {
                app.system.setUserState(.registered)
            }
        default:
            let stateless = userClient.isStateless && userClient.accessToken != nil
            app.system.setUserState(stateless ? .stateless : .unauthenticated)
        }
        app.system.isProcessing = false
    }
    
    func didRegisterUser(profileId: String) {
        let userData = ShowcaseApp.UserData(userId: profileId,
                                         isStateless: stateless,
                                         authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: profileId))
        app.addRegisteredUser(userData, authenticate: true)
        app.system.setEnrollmentState(.unenrolled)
        app.system.setPinPadState(.hidden)
        app.system.setScannerState(.hidden)
        browserChallenge = nil
        customChallenge = nil
        app.setSystemInfo(string: "Profile \(profileId) has been registered successfully.")
    }
}

//MARK: - SDK Delegates
extension RegistrationInteractorReal {

    func didReceiveBrowserRegistrationRedirect(_ url: URL) {
        guard let browserChallenge else { return }
        browserChallenge.sender.respond(with: url, to: browserChallenge)
    }
    
    func didReceiveBrowserRegistrationChallenge(_ challenge: any OneginiSDKiOS.BrowserRegistrationChallenge) {
        setBrowserChallenge(challenge)
        app.system.setUserState(.registering(.browser))
    }
    
    func didReceiveCustomRegistrationFinishChallenge(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) {
        setCustomChallenge(challenge)
        app.system.setUserState(.registering(.api))
        if stateless {
            challenge.sender.respond(with: nil, to: challenge)
        } else {
            /// You can ask the user about the response in different ways, e.g. by scanning the QR code:
            qrScannerInteractor.scan(to: self)
        
            /// or asking for a password, or simply return some dummy response:
            // challenge.sender.respond(with: DummyData.customRegistrationChallenge, to: challenge)
        }
    }
    
    func didFailToRegisterUser(with error: Error) {
        switch SDKError(error) {
        case .statelessDisabled:
            app.setSystemInfo(string: "Stateless registration is not supported or not configured by the server.")
        case .registrationCancelled:
            app.setSystemInfo(string: "Registration has been canceled.")
        default:
            app.setSystemInfo(string: error.localizedDescription)
        }
        browserChallenge = nil
        customChallenge = nil
    }
}

extension RegistrationInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        app.system.setScannerState(.showForRegistration)
    }

    func didCancelScanning() {
        app.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        guard let customChallenge else { return }
        customChallenge.sender.respond(with: code, to: customChallenge)
        app.system.setScannerState(.hidden)
    }
}

private extension RegistrationInteractorReal {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }

    var device: ShowcaseApp.DeviceData { app.deviceData }
}

extension RegistrationInteractorReal: RegistrationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        app.system.isProcessing = false
        if let error = challenge.error {
            pinPadInteractor.setCreatePinChallenge(challenge)
            pinPadInteractor.showError(error)
            return
        }

        app.system.setUserState(.unauthenticated)
        pinPadInteractor.setCreatePinChallenge(challenge)
        pinPadInteractor.showPinPad(for: .creating)
    }

    func userClient(_ userClient: any UserClient, didRegisterUser profile: any UserProfile, with identityProvider: any IdentityProvider, info: (any CustomInfo)?) {
        app.system.isProcessing = false
        didRegisterUser(profileId: profile.profileId)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBrowserRegistrationChallenge challenge: any BrowserRegistrationChallenge) {
        app.system.isProcessing = false
        didReceiveBrowserRegistrationChallenge(challenge)
    }
    
    func userClient(_ userClient: any UserClient, didFailToRegisterUserWith identityProvider: any IdentityProvider, error: any Error) {
        app.system.isProcessing = false
        didFailToRegisterUser(with: error)
    }

    func userClient(_ userClient: any UserClient, didReceiveCustomRegistrationFinishChallenge challenge: any CustomRegistrationChallenge) {
        app.system.isProcessing = false
        didReceiveCustomRegistrationFinishChallenge(challenge)
    }

}
