//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

struct Action: AppModel {
    let name: String
    var description: String? = nil
    var providedValue: Any? = nil
    private(set) var defaultValue: Any? = nil
}

extension Action: Equatable, Hashable {
    static func == (lhs: Action, rhs: Action) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
