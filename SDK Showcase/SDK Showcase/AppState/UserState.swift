//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

enum UserState {
    case notRegistered
    case registering
    case registered
    case authenticated(String)
    
    var userId: String? {
        if case .authenticated(let id) = self {
            return id
        } else {
            return nil
        }
    }
}
