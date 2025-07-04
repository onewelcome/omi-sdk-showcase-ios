//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        @Published var isSDKInitialized = false
        @Published var isRegistered = false
        @Published var isEnrolled = false
        @Published var isMobileEnrolled = false
        @Published var isPushEnrolled = false
        @Published var isError = false
        @Published var lastErrorDescription: String? = nil
        @Published var pinPadState: PinPadState = .hidden
        
        var shouldShowPinPad: Bool {
            get { pinPadState != .hidden }
            set { pinPadState = newValue ? .changing : .hidden }
        }

        func reset() {
            isEnrolled = false
            isRegistered = false
            isSDKInitialized = false
            isMobileEnrolled = false
            isPushEnrolled = false
            isError = false
            lastErrorDescription = nil
        }
    }
}

extension AppState.System {
    static func == (lhs: AppState.System, rhs: AppState.System) -> Bool {
        lhs.isSDKInitialized == rhs.isSDKInitialized &&
        lhs.isEnrolled == rhs.isEnrolled
    }
}
