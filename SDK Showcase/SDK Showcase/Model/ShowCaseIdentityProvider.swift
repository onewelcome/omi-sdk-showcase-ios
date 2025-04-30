//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class ShowCaseIdentityProvider: IdentityProvider {
    static let example = ShowCaseIdentityProvider(identifier: "919dcf6e-1d62-40c6-9b91-fb3e248757b3", name: "demo-cim.onegini.com")
    let identifier: String
    let name: String
    let externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)?
    
    init(identifier: String, name: String, externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)? = nil) {
        self.identifier = identifier
        self.name = name
        self.externalIdentityProvider = externalIdentityProvider
    }
}
