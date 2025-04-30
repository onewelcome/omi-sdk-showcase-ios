//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS

class MyIdentityProvider: IdentityProvider {
    var identifier: String
    var name: String
    var externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)?
    
    init(identifier: String, name: String, externalIdentityProvider: (any OneginiSDKiOS.ExternalIdentityProvider)? = nil) {
        self.identifier = identifier
        self.name = name
        self.externalIdentityProvider = externalIdentityProvider
    }
}
