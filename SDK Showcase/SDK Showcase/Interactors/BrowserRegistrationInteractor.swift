//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import UIKit
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol BrowserRegistrationInteractor {
    var registerUrl: String { get set }
    
    func setChallenge(_ challenge: BrowserRegistrationChallenge)
    func setStateless(_ stateless: Bool)
    
    func register()
    func cancelRegistration()
    func didReceiveBrowserRegistrationChallenge(_ challenge: any BrowserRegistrationChallenge)
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
    func didReceiveCreatePinChallenge(_ challenge: any CreatePinChallenge)
    func didFailToRegisterUser(with error: Error)
    func didRegisterUser(profileId: String)
}

//MARK: - Real methods
class BrowserRegistrationInteractorReal: BrowserRegistrationInteractor {
    @ObservedObject var appState: AppState
    private var challenge: BrowserRegistrationChallenge?
    var registerUrl: String
    var stateless = false

    init(registerUrl: String = "", appState: AppState) {
        self.registerUrl = registerUrl
        self.appState = appState
    }

    func setChallenge(_ challenge: any BrowserRegistrationChallenge) {
        self.registerUrl = challenge.url.absoluteString
        self.challenge = challenge
    }
    
    func setStateless(_ stateless: Bool) {
        self.stateless = stateless
    }
    
    func register() {
        guard appState.system.isSDKInitialized else {
            appState.setSystemInfo(string: "SDK not initialized")
            return
        }
        sdkInteractor.register(with: IdentityProviderProxy.default, stateless: stateless)
    }
    
    func cancelRegistration() {
        guard let challenge else { return }
        
        challenge.sender.cancel(challenge)
        appState.system.setUserState(.registered)
        appState.unsetSystemInfo()
    }
    
    func didRegisterUser(profileId: String) {
        let userData = AppState.UserData(userId: profileId,
                                         isStateless: stateless,
                                         authenticatorsNames: sdkInteractor.authenticatorNames(for: profileId))
        appState.addRegisteredUser(userData)
        appState.system.setEnrollmentState(.unenrolled)
        appState.system.setPinPadState(.hidden)
        challenge = nil
    }
}

//MARK: - SDK Delegates
extension BrowserRegistrationInteractorReal {
    
    func didReceiveCreatePinChallenge(_ challenge: any OneginiSDKiOS.CreatePinChallenge) {
        pinPadInteractor.setCreatePinChallenge(challenge)
        appState.system.setUserState(.registered)
        pinPadInteractor.showPinPad(for: .creating)
    }
    
    func didReceiveBrowserRegistrationRedirect(_ url: URL) {
        guard let challenge else { return }
        challenge.sender.respond(with: url, to: challenge)
    }
    
    func didReceiveBrowserRegistrationChallenge(_ challenge: any OneginiSDKiOS.BrowserRegistrationChallenge) {
        setChallenge(challenge)
        appState.system.setUserState(.registering)
    }
    
    func didFailToRegisterUser(with error: Error) {
        if (error as NSError).code == 9034 {
            appState.setSystemInfo(string: "Stateless registration is not supported or not configured by the server.")
        } else {
            appState.setSystemInfo(string: error.localizedDescription)
        }
        challenge = nil
    }
}

private extension BrowserRegistrationInteractorReal {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }

    var device: AppState.DeviceData { appState.deviceData }
}
