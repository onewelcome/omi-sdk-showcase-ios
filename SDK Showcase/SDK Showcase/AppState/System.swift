//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class System: Equatable, ObservableObject {
        static func == (lhs: AppState.System, rhs: AppState.System) -> Bool {
            lhs.isSDKInitialized == rhs.isSDKInitialized &&
            lhs.isEnrolled == rhs.isEnrolled
        }
        
        @Published var isSDKInitialized = false
        @Published var isRegistered = false
        @Published var isEnrolled = false
        @Published var isMobileEnrolled = false
        @Published var isPushEnrolled = false
        @Published var lastErrorDescription: String? = nil
    }
}
