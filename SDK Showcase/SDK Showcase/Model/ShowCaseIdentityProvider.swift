//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class ShowCaseIdentityProvider: IdentityProvider {
    let identifier: String
    let name: String
    let externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)?
    static let `default` = ShowCaseIdentityProvider(identifier: "919dcf6e-1d62-40c6-9b91-fb3e248757b3", name: "login-mobile.in.prod.onewelcome.net/")

    init(identifier: String, name: String, externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)? = nil) {
        self.identifier = identifier
        self.name = name
        self.externalIdentityProvider = externalIdentityProvider
    }
}
