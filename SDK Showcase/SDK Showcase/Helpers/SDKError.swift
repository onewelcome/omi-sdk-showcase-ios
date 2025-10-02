//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

enum SDKError: Int, Error {
    case unknown
    case accountDeregistered = 9003
    case registrationCancelled = 9006
    case biometricAuthenticationFallback = 9030
    case statelessDisabled = 9034
    
    init(_ error: Error) {
        switch (error as NSError).code {
        case 9003:
            self = .accountDeregistered
        case 9006:
            self = .registrationCancelled
        case 9030:
            self = .biometricAuthenticationFallback
        case 9034:
            self = .statelessDisabled
        default:
            self = .unknown
        }
    }
}
