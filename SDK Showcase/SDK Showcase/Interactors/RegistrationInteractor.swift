//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import UIKit
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol RegistrationInteractor {
    var registerUrl: String { get set }
    
    func setBrowserChallenge(_ challenge: BrowserRegistrationChallenge)
    func setCustomChallenge(_ challenge: CustomRegistrationChallenge)
    func setStateless(_ stateless: Bool)
    func register(with provider: String, stateless: Bool)

    func register(with idp: String?)
    func cancelRegistration()
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
}

//MARK: - Real methods
class RegistrationInteractorReal: RegistrationInteractor {
    @ObservedObject var appState: AppState
    private let userClient = SharedUserClient.instance
    private var browserChallenge: BrowserRegistrationChallenge?
    private var customChallenge: CustomRegistrationChallenge?
    private var stateless = false
    var registerUrl: String

    init(registerUrl: String = "", appState: AppState) {
        self.registerUrl = registerUrl
        self.appState = appState
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
    
    func register(with idp: String?) {
        guard appState.system.isSDKInitialized else {
            appState.setSystemInfo(string: "SDK not initialized")
            return
        }
        register(with: idp ?? IdentityProviderProxy.default.name, stateless: stateless)
    }
    
    
    func register(with provider: String, stateless: Bool) {
        appState.system.isProcessing = true
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
        appState.system.setUserState(stateless ? .stateless : .unauthenticated)
    }
    
    func didRegisterUser(profileId: String) {
        let userData = AppState.UserData(userId: profileId,
                                         isStateless: stateless,
                                         authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: profileId))
        appState.addRegisteredUser(userData)
        appState.system.setEnrollmentState(.unenrolled)
        appState.system.setPinPadState(.hidden)
        appState.system.setScannerState(.hidden)
        browserChallenge = nil
        customChallenge = nil
        appState.setSystemInfo(string: "Profile \(profileId) has been registered successfully.")
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
        appState.system.setUserState(.registering(.browser))
    }
    
    func didReceiveCustomRegistrationFinishChallenge(_ challenge: any OneginiSDKiOS.CustomRegistrationChallenge) {
        setCustomChallenge(challenge)
        appState.system.setUserState(.registering(.api))
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
            appState.setSystemInfo(string: "Stateless registration is not supported or not configured by the server.")
        case .registrationCancelled:
            appState.setSystemInfo(string: "Registration has been canceled.")
        default:
            appState.setSystemInfo(string: error.localizedDescription)
        }
        browserChallenge = nil
        customChallenge = nil
    }
}

extension RegistrationInteractorReal: QRScannerDelegate {
    func didStartScanning() {
        appState.system.setScannerState(.showForRegistration)
    }

    func didCancelScanning() {
        appState.system.setScannerState(.hidden)
    }

    func didFinishScanning(code: String) {
        guard let customChallenge else { return }
        customChallenge.sender.respond(with: code, to: customChallenge)
        appState.system.setScannerState(.hidden)
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

    var device: AppState.DeviceData { appState.deviceData }
}

extension RegistrationInteractorReal: RegistrationDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        appState.system.isProcessing = false
        if let error = challenge.error {
            pinPadInteractor.setCreatePinChallenge(challenge)
            pinPadInteractor.showError(error)
            return
        }

        appState.system.setUserState(.unauthenticated)
        pinPadInteractor.setCreatePinChallenge(challenge)
        pinPadInteractor.showPinPad(for: .creating)
    }

    func userClient(_ userClient: any UserClient, didRegisterUser profile: any UserProfile, with identityProvider: any IdentityProvider, info: (any CustomInfo)?) {
        appState.system.isProcessing = false
        didRegisterUser(profileId: profile.profileId)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBrowserRegistrationChallenge challenge: any BrowserRegistrationChallenge) {
        appState.system.isProcessing = false
        didReceiveBrowserRegistrationChallenge(challenge)
    }
    
    func userClient(_ userClient: any UserClient, didFailToRegisterUserWith identityProvider: any IdentityProvider, error: any Error) {
        appState.system.isProcessing = false
        didFailToRegisterUser(with: error)
    }

    func userClient(_ userClient: any UserClient, didReceiveCustomRegistrationFinishChallenge challenge: any CustomRegistrationChallenge) {
        appState.system.isProcessing = false
        didReceiveCustomRegistrationFinishChallenge(challenge)
    }

}
