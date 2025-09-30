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
    
    func register(with idp: String?)
    func cancelRegistration()
    func didReceiveBrowserRegistrationChallenge(_ challenge: any BrowserRegistrationChallenge)
    func didReceiveCustomRegistrationFinishChallenge(_ challenge: any CustomRegistrationChallenge)
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
    func didReceiveCreatePinChallenge(_ challenge: any CreatePinChallenge)
    func didFailToRegisterUser(with error: Error)
    func didRegisterUser(profileId: String)
}

//MARK: - Real methods
class RegistrationInteractorReal: RegistrationInteractor {

    @ObservedObject var appState: AppState
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
        sdkInteractor.register(with: idp ?? IdentityProviderProxy.default.name, stateless: stateless)
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
        browserChallenge = nil
        customChallenge = nil
        appState.setSystemInfo(string: "Profile \(profileId) has been registered successfully.")
    }
}

//MARK: - SDK Delegates
extension RegistrationInteractorReal {
    
    func didReceiveCreatePinChallenge(_ challenge: any OneginiSDKiOS.CreatePinChallenge) {
        pinPadInteractor.setCreatePinChallenge(challenge)
        appState.system.setUserState(.unauthenticated)
        pinPadInteractor.showPinPad(for: .creating)
    }
    
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
            //You can ask the user about the response in different ways (e.g. by scanning the QR code, asking for a password, etc.)
            //TODO: add some mapping for different IDPs in the next PR
            challenge.sender.respond(with: DummyData.customRegistrationChallenge, to: challenge)
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

    var device: AppState.DeviceData { appState.deviceData }
}
