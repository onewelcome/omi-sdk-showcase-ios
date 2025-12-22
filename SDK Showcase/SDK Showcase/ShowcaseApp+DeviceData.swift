//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension ShowcaseApp {
    class DeviceData: ObservableObject {
        var deviceId: String?
        @Published var model: SDKConfigModel?
        @Published var certs = [String]()
        @Published var publicKey: String?
        
        func reset() {
            model = nil
            publicKey = nil
            deviceId = nil
            certs.removeAll()
        }
    }
}

extension ShowcaseApp.DeviceData: Equatable {
    static func == (lhs: ShowcaseApp.DeviceData, rhs: ShowcaseApp.DeviceData) -> Bool {
        lhs.deviceId == rhs.deviceId
    }
}
