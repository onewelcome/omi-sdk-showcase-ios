//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

struct SDKConfigModel {
    let dictionary: [String: String]
    var appIdentifier: String?
    var appPlatform: String?
    var appVersion: String?
    var serverType: String?
    var serverVersion: String?
    var baseURL: String?
    var resourceBaseURL: String?
    var redirectURL: String?
    var appScheme: String?
    
    /// Default config model
    static let `default` = SDKConfigModel(dictionary: ["ONGAppIdentifier": "ExampleApp",
                                                       "ONGAppPlatform": "ios",
                                                       "ONGAppVersion": "6.2.4",
                                                       "ONGAppBaseURL": "https://mobile-security-proxy.onegini.com",
                                                       "ONGResourceBaseURL": "https://mobile-security-proxy.onegini.com/resources/",
                                                       "ONGRedirectURL": "oneginiexample://loginsuccess"])
}
