//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

enum UserState {
    case notRegistered
    case registering
    case registered
    case authenticated(String)
}
