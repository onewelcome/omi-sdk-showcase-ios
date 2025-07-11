//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

enum RegistrationState {
    case notRegistered
    case registering
    case registered([AppState.UserData])
}
