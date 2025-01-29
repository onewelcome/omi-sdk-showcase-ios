//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

protocol AppModel: Identifiable {}

protocol Runable {
    func run() 
}

extension AppModel {
    var id: UUID { UUID() }
}
