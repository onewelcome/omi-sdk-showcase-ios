//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

extension AppState {
    enum UserState {
        case notRegistered
        case registering
        case registered
        case authenticated(String)
    }
}
