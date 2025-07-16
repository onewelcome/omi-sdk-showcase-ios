//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isEnrolled = false
        @Published var isMobileEnrolled = false
        @Published var isPushEnrolled = false
        @Published var lastErrorDescription: String? = nil
        @Published private var previousUserState: UserState?
        @Published var userState: UserState = .notRegistered {
            willSet { previousUserState = userState }
        }
        @Published var pinPadState: PinPadState = .hidden
        
        var hasError: Bool {
            lastErrorDescription != nil
        }
                
        var shouldShowBrowser: Bool {
            get { if case .registering = userState { return true } else { return false } }
            set {
                if newValue {
                    userState = .registering
                }
            }
        }
        
        func restorePreviousUserState() {
            userState = previousUserState ?? .notRegistered
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
            
            userState = .notRegistered
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
