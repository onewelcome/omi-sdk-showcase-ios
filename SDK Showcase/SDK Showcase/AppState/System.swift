//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isEnrolled = false
        @Published var isMobileEnrolled = false
        @Published var isPushEnrolled = false
        @Published var lastInfoDescription: String? = nil
        @Published private var previousUserState: UserState?
        @Published private(set) var userState: UserState = .notRegistered
        @Published var pinPadState: PinPadState = .hidden
        
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
            isEnrolled = false
            isSDKInitialized = false
            isMobileEnrolled = false
            isPushEnrolled = false
            
            userState = .notRegistered
            pinPadState = .hidden
            
            unsetInfo()
        }
    }
}

extension AppState.System {
    static func == (lhs: AppState.System, rhs: AppState.System) -> Bool {
        lhs.isSDKInitialized == rhs.isSDKInitialized &&
        lhs.isEnrolled == rhs.isEnrolled
    }
}
