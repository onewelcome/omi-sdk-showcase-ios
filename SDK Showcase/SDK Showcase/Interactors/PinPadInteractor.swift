//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol
protocol PinPadInteractor {
    var pinLength: UInt { get }
    
    func changePin()
    func setPinChallenge(_ challenge: PinChallenge)
    func setCreatePinChallenge(_ challenge: CreatePinChallenge)
    func showPinPad(for state: PinPadState)
    func validate(pin: String)
    func showError(_ error: Error)
    func cancelChangingPIN()
    func cancelCreatingPIN()
    func didChangePinForUser()
}

//MARK: - Real methods
class PinPadInteractorReal: PinPadInteractor {
    @Injected var appState: AppState
    private let userClient = SharedUserClient.instance
    private var providedPin: String?
    private var pinChallenge: PinChallenge?
    private var createPinChallenge: CreatePinChallenge?

    var pinLength: UInt {
        return createPinChallenge?.pinLength ?? 5
    }

    func setPinChallenge(_ challenge: PinChallenge) {
        pinChallenge = challenge
    }
    
    func setCreatePinChallenge(_ challenge: CreatePinChallenge) {
        createPinChallenge = challenge
    }
    
    func showError(_ error: any Error) {
        appState.setSystemInfo(string: error.localizedDescription)
    }
    
    func cancelChangingPIN() {
        guard let pinChallenge else { return }
        
        pinChallenge.sender.cancel(pinChallenge)
        appState.unsetSystemInfo()
        self.pinChallenge = nil
    }
    
    func changePin() {
        userClient.changePin(delegate: self)
    }
    
    func cancelCreatingPIN() {
        guard let createPinChallenge else { return }
        
        createPinChallenge.sender.cancel(createPinChallenge)
        appState.unsetSystemInfo()
        self.createPinChallenge = nil
    }
    
    func showPinPad(for state: PinPadState) {
        providedPin = nil
        appState.system.setPinPadState(state)
    }
    
    func validate(pin: String) {
        if let providedPin, providedPin != pin {
            appState.setSystemInfo(string: "Provided PIN does not match the previous one")
            return
        }
        
        guard appState.system.pinPadState == .creating else {
            handleValidatedPin(pin)
            return
        }
        
        validatePolicy(for: pin) { [self] error in
            if let error {
                showError(error)
            } else {
                handleValidatedPin(pin)
            }
        }
    }
    
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void) {
        userClient.validatePolicyCompliance(for: pin) { error in
            completion(error)
        }
    }
    
    func didChangePinForUser() {
        appState.system.setPinPadState(.hidden)
        pinChallenge = nil
    }
}

private extension PinPadInteractorReal {
    var interactor: SDKInteractor {
         @Injected var interactors: Interactors
         return interactors.sdkInteractor
    }
    
    func handleValidatedPin(_ pin: String) {
        switch appState.system.pinPadState {
        case .biometricFallback:
            appState.system.setPinPadState(.hidden)
            handleChallenge(for: pin)
        case .creating:
            appState.system.setPinPadState(.created)
            providedPin = pin
        case .created:
            appState.unsetSystemInfo()
            handleChallenge(for: pin)
        case .changing, .authenticating:
            appState.unsetSystemInfo()
            handleChallenge(for: pin)
        case .hidden:
            break
        }
    }

    func handleChallenge(for pin: String) {
        if let pinChallenge {
            pinChallenge.sender.respond(with: pin, to: pinChallenge)
            self.pinChallenge = nil
        }
        if let createPinChallenge {
            createPinChallenge.sender.respond(with: pin, to: createPinChallenge)
            self.createPinChallenge = nil
        }
    }
}

extension PinPadInteractorReal: ChangePinDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        appState.system.setUserState(.unauthenticated)
        appState.system.setPinPadState(.hidden)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.setCreatePinChallenge(challenge)
            self.showPinPad(for: .creating)
        }
    }
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceivePinChallenge challenge: any OneginiSDKiOS.PinChallenge) {
        setPinChallenge(challenge)
        if let _ = challenge.error {
            appState.setSystemInfo(string: "Wrong previous PIN, please try again (\(challenge.remainingFailureCount))")
            return
        }
        appState.system.isProcessing = false
        showPinPad(for: .changing)
    }
    
    func userClient(_ userClient: any UserClient, didChangePinForUser profile: any UserProfile) {
        appState.system.isProcessing = false
        didChangePinForUser()
    }

    func userClient(_ userClient: any UserClient, didFailToChangePinForUser profile: any UserProfile, error: any Error) {
        appState.system.isProcessing = false
        appState.setSystemInfo(string: error.localizedDescription)
    }
}
