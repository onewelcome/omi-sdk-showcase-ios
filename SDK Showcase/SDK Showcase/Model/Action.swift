//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

struct Action: AppModel {
    let name: String
    let description: String
    var providedValue: Any? = nil
    private(set) var defaultValue: Any? = nil
    private(set) var valueType: ActionType = .string
}

extension Action: Equatable, Hashable {
    static func == (lhs: Action, rhs: Action) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
