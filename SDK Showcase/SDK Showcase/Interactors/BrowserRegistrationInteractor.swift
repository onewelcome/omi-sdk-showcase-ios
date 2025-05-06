//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import UIKit
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol BrowserRegistrationInteractor {
    var registerUrl: String { get set }
    
    func setChallenge(_ challenge: BrowserRegistrationChallenge)
    func register(completion: @escaping () -> Void)
    
    func didReceiveBrowserRegistrationChallenge(_ challenge: any BrowserRegistrationChallenge)
    func didReceiveBrowserRegistrationRedirect(_ url: URL)
    func didReceiveCreatePinChallenge(_ challenge: any CreatePinChallenge)
    func didFailToRegisterUser(with error: Error)
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
    
    func register(completion: @escaping () -> Void) {
        guard appState.system.isSDKInitialized else {
            appState.system.lastErrorDescription = "SDK not initialized"
            return
        }
        sdkInteractor.register(with: ShowCaseIdentityProvider.example, completion: completion)
    }
}

//MARK: - SDK Delegates
extension BrowserRegistrationInteractorReal {
    
    func didReceiveCreatePinChallenge(_ challenge: any OneginiSDKiOS.CreatePinChallenge) {
        //TODO: Next story to handle PIN creation
        challenge.sender.respond(with: "21370", to: challenge)
    }
    
    func didReceiveBrowserRegistrationRedirect(_ url: URL) {
        guard let challenge else { return }
        challenge.sender.respond(with: url, to: challenge)
    }
    
    func didReceiveBrowserRegistrationChallenge(_ challenge: any OneginiSDKiOS.BrowserRegistrationChallenge) {
        setChallenge(challenge)
    }
    
    func didFailToRegisterUser(with error: Error) {
        appState.system.isRegistered = false
        appState.system.lastErrorDescription = error.localizedDescription
    }

}

private extension BrowserRegistrationInteractorReal {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }

    var device: AppState.DeviceData { appState.deviceData }
}
