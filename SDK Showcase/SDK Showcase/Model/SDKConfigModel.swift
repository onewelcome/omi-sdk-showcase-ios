//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

struct SDKConfigModel {
    let dictionary: [String: String]
    let appIdentifier: String? = nil
    let appPlatform: String? = nil
    let appVersion: String? = nil
    let serverType: String? = nil
    let serverVersion: String? = nil
    let baseURL: String? = nil
    let resourceBaseURL: String? = nil
    let redirectURL: String? = nil
    let appScheme: String? = nil
    
    /// Default config model
    static let `default` = SDKConfigModel(dictionary: ["ONGAppIdentifier": "ExampleApp",
                                                       "ONGAppPlatform": "ios",
                                                       "ONGAppVersion": "6.2.4",
                                                       "ONGAppBaseURL": "https://mobile-security-proxy.onegini.com",
                                                       "ONGResourceBaseURL": "https://mobile-security-proxy.onegini.com/resources/",
                                                       "ONGRedirectURL": "oneginiexample://loginsuccess"])
}
