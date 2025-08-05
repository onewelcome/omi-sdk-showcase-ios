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
        Category(name: Categories.initialization.rawValue,
                 description: "The SDK has to be initialized before any other operation",
                 options: [Option(name: Options.initialize.rawValue,
                                  logo: "figure.run"),
                           Option(name: Options.reset.rawValue)],
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
        Category(name: Categories.userRegistation.rawValue,
                 description: "You can register your account here",
                 options: [],
                 selection: [Selection(name: "Browser registration"),
                             Selection(name: "Cancel registration", disabled: true)],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: Categories.userAuthentication.rawValue,
                 description: "Here you can see all registered authenticators for the registered user.",
                 options: [],
                 selection: userAuthenticationSelections,
                 requiredActions: [],
                 optionalActions: []),
        Category(name: Categories.mobileAuthentication.rawValue,
                 description: "Here you can enroll your device for mobile authentication and register for push notifications. ",
                 options: [Option(name: Options.enroll.rawValue, logo: "iphone"),
                           Option(name: Options.pushes.rawValue, logo: "app.badge")],
                 selection: [Selection(name: Selections.loginWithOtp.rawValue, disabled: true)],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: Categories.pendingTransactions.rawValue,
                 description: "The list of transactions waiting to be confirmed.",
                 options: [],
                 selection: mobileAuthPendingTransactionsSelections,
                 requiredActions: [],
                 optionalActions: []),
        Category(name: Categories.userDeregistation.rawValue,
                 description: "You can deregister your account here",
                 options: [],
                 selection: [],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: Categories.pinChange.rawValue,
                 description: "You can change your PIN here",
                 options: [Option(name: Options.changePin.rawValue,
                                  logo: "pin")],
                 selection: [],
                 requiredActions: [],
                 optionalActions: []),
    ]}
}

private extension CategoriesInteractorReal {
    var userAuthenticationSelections: [Selection] {
        interactor.userAuthenticatorOptionNames.map { Selection(name: $0) }
    }
    
    var mobileAuthPendingTransactionsSelections: [Selection] {
        interactor.mobileAuthPendingTransactionNames.map { Selection(name: $0) }
    }
}
