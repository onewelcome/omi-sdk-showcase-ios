//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import UIKit
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol BrowserRegistrationInteractor {
    var registerUrl: String { get set }
    
    func setChallenge(_ challenge: BrowserRegistrationChallenge)
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

    init(registerUrl: String = "", appState: AppState) {
        self.registerUrl = registerUrl
        self.appState = appState
    }

    func setChallenge(_ challenge: any BrowserRegistrationChallenge) {
        self.registerUrl = challenge.url.absoluteString
        self.challenge = challenge
    }
    
    func register() {
        guard appState.system.isSDKInitialized else {
            appState.setSystemInfo(string: "SDK not initialized")
            return
        }
        sdkInteractor.register(with: IdentityProviderProxy.default)
    }
    
    func cancelRegistration() {
        guard let challenge else { return }
        
        challenge.sender.cancel(challenge)
        appState.unsetSystemInfo()
    }
    
    func didRegisterUser(profileId: String) {
        appState.addRegisteredUser(.init(userId: profileId))
        appState.system.setEnrollmentState(.unenrolled)
        appState.system.setPinPadState(.hidden)
        challenge = nil
    }
}

//MARK: - SDK Delegates
extension BrowserRegistrationInteractorReal {
    
    func didReceiveCreatePinChallenge(_ challenge: any OneginiSDKiOS.CreatePinChallenge) {
        pinPadInteractor.setCreatePinChallenge(challenge)
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
        appState.system.restorePreviousUserState()
        appState.setSystemInfo(string: error.localizedDescription)
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
