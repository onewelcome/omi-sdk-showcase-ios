//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isProcessing = false

        @Published private(set) var lastInfoDescription: String? = nil
        @Published private(set) var userState: UserState = .notRegistered
        @Published private(set) var enrollmentState: EnrollmentState = .unenrolled
        @Published private(set) var pinPadState: PinPadState = .hidden
        @Published private(set) var scannerState: ScannerState = .hidden

        var hasError: Bool {
            lastInfoDescription != nil
        }
                
        var shouldShowBrowser: Bool {
            get {
                switch userState {
                case .registering(let type):
                    return type == .browser
                case .sso:
                    return true
                default:
                    return false
                }
            }
            set {
                if newValue {
                    userState = .registering(.browser)
                }
            }
        }
        
        func setScannerState(_ newState: ScannerState) {
            scannerState = newState
        }
        
        func setUserState(_ newState: UserState) {
            userState = newState
        }
        
        func setEnrollmentState(_ newState: EnrollmentState) {
            enrollmentState = newState
        }
        
        func setPinPadState(_ newState: PinPadState) {
            pinPadState = newState
        }
   
        var shouldShowPinPad: Bool {
            get { pinPadState != .hidden }
            set { pinPadState = newValue ? .changing : .hidden }
        }
        
        var shouldShowScanner: Bool {
            get { scannerState != .hidden }
            set { scannerState = newValue ? .showForOTP : .hidden }
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
