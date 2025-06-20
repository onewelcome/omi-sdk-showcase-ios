//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class AppState: ObservableObject {
    @Published var system = System()
    @Published var deviceData = DeviceData()
    @Published var userData = UserData()
    
    func reset() {
        system.reset()
        deviceData.reset()
        userData.reset()
    }
}

//MARK: - Equatable

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system &&
        lhs.userData == rhs.userData
    }
}
