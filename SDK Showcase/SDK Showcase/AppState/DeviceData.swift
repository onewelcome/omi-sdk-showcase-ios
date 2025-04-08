//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import OneginiSDKiOS

extension AppState {
    class DeviceData: Equatable, ObservableObject {
        static func == (lhs: AppState.DeviceData, rhs: AppState.DeviceData) -> Bool {
            lhs.deviceId == rhs.deviceId
        }
        
        var deviceId: String?
        @Published var configModel: ConfigModel?
        @Published var certs = [String]()
        @Published var publicKey: String?
    }
}
