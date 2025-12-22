//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

struct Devices: Codable {
    var devices: [Device]
}

struct Device: Codable {
    var name: String
    var id: String
    var application: String
}
