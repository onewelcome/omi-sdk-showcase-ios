//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol
protocol PinPadInteractor {
    var pinLength: UInt { get }
    
    func setChallenge(_ challenge: CreatePinChallenge)
    func showPinPad()
    func validate(pin: String)
    func showError(_ error: Error)
}

//MARK: - Real methods
class PinPadInteractorReal: PinPadInteractor {
    @Injected var appState: AppState
    private var providedPin: String?
    private var pinChallenge: CreatePinChallenge?
    
    var pinLength: UInt {
        return pinChallenge?.pinLength ?? 5
    }

    func setChallenge(_ challenge: CreatePinChallenge) {
        pinChallenge = challenge
    }
    
    func showError(_ error: any Error) {
        appState.system.lastErrorDescription = error.localizedDescription
    }
    
    func showPinPad() {
        providedPin = nil
        appState.system.isPreregistered = true
    }
    
    func validate(pin: String) {
        guard let pinChallenge else { return }
        if let providedPin, providedPin != pin {
            appState.system.lastErrorDescription = "Provided PIN does not match the previous one"
            return
        }
        
        interactor.validatePolicy(for: pin) { [self] error in
            guard let error else {
                if !appState.system.isPinProvided {
                    appState.system.isPinProvided = true
                    providedPin = pin
                } else {
                    appState.system.lastErrorDescription = nil
                    pinChallenge.sender.respond(with: pin, to: pinChallenge)
                }
                
                return
            }
            
            showError(error)
        }
        

    }
    
    private var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
}
