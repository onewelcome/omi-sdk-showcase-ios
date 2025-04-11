//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension AppState {
    class DeviceData: ObservableObject {
        var deviceId: String?
        @Published var model: SDKConfigModel?
        @Published var certs = [String]()
        @Published var publicKey: String?
    }
}

extension AppState.DeviceData: Equatable {
    static func == (lhs: AppState.DeviceData, rhs: AppState.DeviceData) -> Bool {
        lhs.deviceId == rhs.deviceId
    }
}
