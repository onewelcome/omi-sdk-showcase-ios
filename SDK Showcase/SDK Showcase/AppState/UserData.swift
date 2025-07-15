//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class UserData: Equatable, ObservableObject {
        let userId: String
        let isStateless: Bool
        
        init(userId: String, isStateless: Bool = false) {
            self.userId = userId
            self.isStateless = isStateless
        }
        
        static func == (lhs: AppState.UserData, rhs: AppState.UserData) -> Bool {
            lhs.userId == rhs.userId &&
            lhs.isStateless == rhs.isStateless
        }
    }
}
