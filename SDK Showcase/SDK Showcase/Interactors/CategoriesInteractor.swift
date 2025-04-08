//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

//MARK: - Protocol
protocol CategoriesInteractor {
    func loadCategories() -> [Category]
    func category(id: UUID) -> Category?
}

//MARK: - Real methods
struct CategoriesInteractorReal: CategoriesInteractor {
    func category(id: UUID) -> Category? {
        loadCategories().first { $0.id == id }
    }
    
    @Injected var appState: AppState

    func loadCategories() -> [Category] {
        //TODO: Load from a universal JSON for both platforms.
        return []
    }
}

//MARK: - Stubbed methods
struct CategoriesInteractorStub: CategoriesInteractor {
    private var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    func category(id: UUID) -> Category? {
        loadCategories().first
    }
    
    func loadCategories() -> [Category] {[
      

        Category(name: "SDK Initialization",
                 description: "Description of SDK Initialization...",
                 options: [Option(name: "Initialize",
                                  logo: "figure.run"),
                           Option(name: "Reset")],
                 requiredActions: [Action(name: "setConfigModel",
                                          description: "Sets config model"),
                                   Action(name: "setX509PEMCertificates",
                                          description: "Sets PEM certificates",
                                          defaultValue: "C1X1"),
                                   Action(name: "setPublicKey",
                                          description: "Sets public key",
                                          defaultValue: "P111"),
                 ],
                 optionalActions: [Action(name: "setAdditionalResourceURL",
                                          description: "Sets additional source"),
                                   Action(name: "setDeviceConfigCacheDuration",
                                          description: "Sets the device config's cache duration",
                                          defaultValue: "60"),
                                   Action(name: "setHttpRequestTimeout",
                                          description: "Sets HTTP request timeout",
                                          defaultValue: "30"),
                                   Action(name: "setStoreCookies",
                                          description: "Sets a flag which alows to store cookies",
                                          defaultValue: "true",
                                          type: .boolean),
                 ]),
        Category(name: "User registration",
                 description: "Description of User registration...",
                 options: [],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: "User deregistration", 
                 description: "Description of User deregistration...",
                 options: [],
                 requiredActions: [],
                 optionalActions: []),
        /*
         
         ... other categories
         
         */
    ]}
}
