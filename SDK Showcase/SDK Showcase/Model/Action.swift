//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

struct Action: AppModel {
    let name: String
    let description: String
    var defaultValue: String = ""
    var boolValue = false
    var value: String = ""
    var type: ActionType = .string
}

