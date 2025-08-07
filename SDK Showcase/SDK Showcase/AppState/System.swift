//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var shouldShowQRScanner = false
        @Published var isProcessing = false

        @Published private(set) var lastInfoDescription: String? = nil
        @Published private(set) var previousUserState: UserState?
        @Published private(set) var userState: UserState = .notRegistered
        @Published private(set) var enrollmentState: EnrollmentState = .unenrolled
        @Published private(set) var pinPadState: PinPadState = .hidden
        
        var hasError: Bool {
            lastInfoDescription != nil
        }
                
        var shouldShowBrowser: Bool {
            get { if case .registering = userState { return true } else { return false } }
            set {
                if newValue {
                    userState = .registering
                } else {
                    restorePreviousUserState()
                }
            }
        }
        
        func setUserState(_ newState: UserState) {
            previousUserState = userState
            userState = newState
        }
        
        func setEnrollmentState(_ newState: EnrollmentState) {
            enrollmentState = newState
        }
        
        func setPinPadState(_ newState: PinPadState) {
            pinPadState = newState
        }
        
        func restorePreviousUserState() {
            userState = previousUserState ?? .notRegistered
        }
        
        var shouldShowPinPad: Bool {
            get { pinPadState != .hidden }
            set { pinPadState = newValue ? .changing : .hidden }
        }
        
        func setInfo(_ description: String) {
            lastInfoDescription = description
        }
        
        func unsetInfo() {
            lastInfoDescription = nil
        }

        func reset() {
            isSDKInitialized = false

            enrollmentState = .unenrolled
            userState = .notRegistered
            pinPadState = .hidden
            
            unsetInfo()
        }
    }
}

extension AppState.System {
    static func == (lhs: AppState.System, rhs: AppState.System) -> Bool {
        lhs.isSDKInitialized == rhs.isSDKInitialized &&
        lhs.enrollmentState == rhs.enrollmentState
    }
}
