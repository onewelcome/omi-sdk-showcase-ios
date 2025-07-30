//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class UserData: Equatable, ObservableObject {
        let userId: String
        let isStateless: Bool
        let authenticatorsNames: [String]
        
        init(userId: String, isStateless: Bool = false, authenticatorsNames: [String]) {
            self.userId = userId
            self.isStateless = isStateless
            self.authenticatorsNames = authenticatorsNames
        }
        
        static func == (lhs: AppState.UserData, rhs: AppState.UserData) -> Bool {
            lhs.userId == rhs.userId &&
            lhs.isStateless == rhs.isStateless
        }
    }
}

extension AppState.UserData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
        hasher.combine(isStateless)
    }
}
