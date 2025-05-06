//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

struct Category: AppModel {
    let name: String
    let description: String
    let options: [Option]
    let selection: [Selection]
    let requiredActions: [Action]
    let optionalActions: [Action]
}
