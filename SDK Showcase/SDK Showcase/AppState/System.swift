//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isEnrolled = false
        @Published var isMobileEnrolled = false
        @Published var isPushEnrolled = false
        @Published var lastErrorDescription: String? = nil
        @Published var registrationState: RegistrationState = .notRegistered
        @Published var authenticationState: AuthenticationState = .notAuthenticated
        @Published var pinPadState: PinPadState = .hidden
        
        var hasError: Bool {
            lastErrorDescription != nil
        }
                
        var shouldShowBrowser: Bool {
            get { if case .registering = registrationState { return true } else { return false } }
            set { registrationState = newValue ? .registering : .notRegistered }
        }
        
        var shouldShowPinPad: Bool {
            get { pinPadState != .hidden }
            set { pinPadState = newValue ? .changing : .hidden }
        }
        
        func setError(_ description: String) {
            lastErrorDescription = description
        }
        
        func unsetError() {
            lastErrorDescription = nil
        }

        func reset() {
            isEnrolled = false
            isSDKInitialized = false
            isMobileEnrolled = false
            isPushEnrolled = false
            
            registrationState = .notRegistered
            authenticationState = .notAuthenticated
            pinPadState = .hidden
            
            unsetError()
        }
    }
}

extension AppState.System {
    static func == (lhs: AppState.System, rhs: AppState.System) -> Bool {
        lhs.isSDKInitialized == rhs.isSDKInitialized &&
        lhs.isEnrolled == rhs.isEnrolled
    }
}
