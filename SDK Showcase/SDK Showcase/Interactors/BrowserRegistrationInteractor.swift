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
            appState.setSystemError(string: "SDK not initialized")
            return
        }
        sdkInteractor.register(with: ShowCaseIdentityProvider.default)
    }
    
    func cancelRegistration() {
        guard let challenge else { return }
        
        challenge.sender.cancel(challenge)
        appState.unsetSystemError()
    }
    
    func didRegisterUser(profileId: String) {
        var registeredUsers = [AppState.UserData]()
        
        if case var .registered(users) = appState.system.registrationState {
            users.removeAll { user in
                user.userId == profileId
            }
            registeredUsers = users
        }

        let newUser: AppState.UserData = {
            let newUser = AppState.UserData()
            newUser.userId = profileId
            return newUser
        }()
        registeredUsers.append(newUser)

        
        appState.system.registrationState = .registered(registeredUsers)
        appState.system.pinPadState = .hidden
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
        appState.system.registrationState = .registering
    }
    
    func didFailToRegisterUser(with error: Error) {
        appState.system.registrationState = .notRegistered
        appState.setSystemError(string: error.localizedDescription)
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
