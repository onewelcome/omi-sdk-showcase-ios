//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class AppState: ObservableObject {
    @Published var system = System()
    @Published var deviceData = DeviceData()
    @Published var userData = UserData()
    
    func reset() {
        system.isEnrolled = false
        system.isRegistered = false
        system.isSDKInitialized = false
        system.isMobileEnrolled = false
        system.isPushEnrolled = false
        
        deviceData.certs.removeAll()
        deviceData.deviceId = nil
        deviceData.model = nil
        deviceData.publicKey = nil
        
        userData.isStateless = false
        userData.userId = nil
    }
}

//MARK: - Equatable

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system &&
        lhs.userData == rhs.userData
    }
}
