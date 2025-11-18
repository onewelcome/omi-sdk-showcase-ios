//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

enum Options: String {
    case unknown
    case initialize = "Initialize"
    case autoinitialize = "Autoinitialize"
    case reset = "Reset"
    case changePin = "Change Pin"
    case registerAuthenticator = "Register an authenticator"
    case enroll = "Enroll for mobile authentication"
    case pushes = "Register for push notifications"
    case cancel = "Cancel registration"
    case sso = "Single Sign On"
    case deviceAuthentication = "Device authentication"
}

struct Option: AppModel {
    let name: String
    var type: Options {
        return Options(rawValue: name) ?? .unknown
    }
    
    private(set) var logo: String?
}
