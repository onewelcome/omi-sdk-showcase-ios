//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

struct ApplicationDetails: Codable {
    private enum CodingKeys: String, CodingKey {
        case appId = "application_identifier"
        case appVersion = "application_version"
        case appPlatform = "application_platform"
    }

    let appId: String
    let appVersion: String
    let appPlatform: String
}
