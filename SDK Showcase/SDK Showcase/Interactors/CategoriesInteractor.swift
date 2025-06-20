//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

//MARK: - Protocol
protocol CategoriesInteractor {
    func loadCategories() -> [Category]
}

//MARK: - Real methods
struct CategoriesInteractorReal: CategoriesInteractor {
    private var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
        
    func loadCategories() -> [Category] {[
        Category(name: "SDK Initialization",
                 description: "Description of SDK Initialization...",
                 options: [Option(name: "Initialize",
                                  logo: "figure.run"),
                           Option(name: "Reset")],
                 selection: [],
                 requiredActions: [Action(name: "setConfigModel",
                                          description: "Sets config model"),
                                   Action(name: "setX509PEMCertificates",
                                          description: "Sets PEM certificates",
                                          defaultValue: SDKConfigModel.defaultCert),
                                   Action(name: "setPublicKey",
                                          description: "Sets public key",
                                          defaultValue: SDKConfigModel.defaultPublicKey),
                 ],
                 optionalActions: [Action(name: "setAdditionalResourceURL",
                                          description: "Sets additional source"),
                                   Action(name: "setDeviceConfigCacheDuration",
                                          description: "Sets the device config's cache duration",
                                          defaultValue: 60.0),
                                   Action(name: "setHttpRequestTimeout",
                                          description: "Sets HTTP request timeout",
                                          defaultValue: 30.0),
                                   Action(name: "setStoreCookies",
                                          description: "Sets a flag which alows to store cookies",
                                          defaultValue: true),
                 ]),
        Category(name: "User registration",
                 description: "Description of User registration...",
                 options: [],
                 selection: [Selection(name: "Browser registration"),
                             Selection(name: "Cancel registration", disabled: true)],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: "User deregistration",
                 description: "Description of User deregistration...",
                 options: [],
                 selection: [],
                 requiredActions: [],
                 optionalActions: []),
    ]}
}
