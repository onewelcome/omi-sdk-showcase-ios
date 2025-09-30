//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

enum UserState: Equatable {
    case notRegistered
    case registering(IdentityProviderType)
    case registered
    case unauthenticated
    case authenticated(String)
    case stateless
    
    var userId: String? {
        switch self {
        case .authenticated(let id):
            return id
        case .stateless:
            return rawValue
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .notRegistered:
            return "notRegistered"
        case .registering:
            return "registering"
        case .registered:
            return "registered"
        case .authenticated(let id):
            return "authenticated(\(id))"
        case .unauthenticated:
            return "unauthenticated"
        case .stateless:
            return "stateless"
        }
    }
}
