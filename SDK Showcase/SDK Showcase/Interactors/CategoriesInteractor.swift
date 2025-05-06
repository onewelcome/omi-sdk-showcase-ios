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
                                          defaultValue: "MIICnzCCAiWgAwIBAgIQf/MZd5csIkp2FV0TttaF4zAKBggqhkjOPQQDAzBHMQswCQYDVQQGEwJVUzEiMCAGA1UEChMZR29vZ2xlIFRydXN0IFNlcnZpY2VzIExMQzEUMBIGA1UEAxMLR1RTIFJvb3QgUjQwHhcNMjMxMjEzMDkwMDAwWhcNMjkwMjIwMTQwMDAwWjA7MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVR29vZ2xlIFRydXN0IFNlcnZpY2VzMQwwCgYDVQQDEwNXRTEwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARvzTr+Z1dHTCEDhUDCR127WEcPQMFcF4XGGTfn1XzthkubgdnXGhOlCgP4mMTG6J7/EFmPLCaY9eYmJbsPAvpWo4H+MIH7MA4GA1UdDwEB/wQEAwIBhjAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUkHeSNWfE/6jMqeZ72YB5e8yT+TgwHwYDVR0jBBgwFoAUgEzW63T/STaj1dj8tT7FavCUHYwwNAYIKwYBBQUHAQEEKDAmMCQGCCsGAQUFBzAChhhodHRwOi8vaS5wa2kuZ29vZy9yNC5jcnQwKwYDVR0fBCQwIjAgoB6gHIYaaHR0cDovL2MucGtpLmdvb2cvci9yNC5jcmwwEwYDVR0gBAwwCjAIBgZngQwBAgEwCgYIKoZIzj0EAwMDaAAwZQIxAOcCq1HW90OVznX+0RGU1cxAQXomvtgM8zItPZCuFQ8jSBJSjz5keROv9aYsAm5VsQIwJonMaAFi54mrfhfoFNZEfuNMSQ6/bIBiNLiyoX46FohQvKeIoJ99cx7sUkFN7uJW"),
                                   Action(name: "setPublicKey",
                                          description: "Sets public key",
                                          defaultValue: "59EE67A85633FFC8D40A4B226FA5F8DDDA5BFA22D959DD581E71CD39D446DECA"),
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
                 selection: [Selection(name: "Browser registration")],
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
