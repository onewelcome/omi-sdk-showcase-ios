//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

enum Categories: String {
    case unknown
    case initialization = "SDK Initialization"
    case userRegistation = "User registration"
    case userAuthentication = "User authentication"
    case mobileAuthentication = "Mobile authentication"
    case pendingTransactions = "Pending transactions"
    case userLogout = "User logout"
    case userDeregistation = "User deregistration"
    case pinChange = "PIN change"
    case tokens = "Tokens"
}

struct Category: AppModel {
    let name: String
    var type: Categories {
        return Categories(rawValue: name) ?? .unknown
    }
    let description: String
    let options: [Option]
    var selections: [Selection]
    let requiredActions: [Action]
    let optionalActions: [Action]
}
