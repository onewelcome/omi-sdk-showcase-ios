//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

enum Selections: String {
    case unknown
    case cancelRegistration = "Cancel registration"
    case browserRegistration = "Browser registration"
}

struct Selection: AppModel {
    let name: String
    var disabled = false
    var type: Selections {
        return Selections(rawValue: name) ?? .unknown
    }
    
    private(set) var logo: String?
}
