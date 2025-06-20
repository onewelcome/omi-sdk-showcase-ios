//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class UserData: Equatable, ObservableObject {
        var userId: String?
        var isStateless = false
        
        static func == (lhs: AppState.UserData, rhs: AppState.UserData) -> Bool {
            lhs.userId == rhs.userId &&
            lhs.isStateless == rhs.isStateless
        }
        
        func reset() {
            isStateless = false
            userId = nil
        }
    }
}
