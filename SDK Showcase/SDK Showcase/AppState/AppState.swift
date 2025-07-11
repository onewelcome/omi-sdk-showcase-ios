//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class AppState: ObservableObject {
    @Published var system = System()
    @Published var deviceData = DeviceData()
    
    func reset() {
        system.reset()
        deviceData.reset()
    }
    
    func setSystemError(string: String) {
        system.setError(string)
    }
    
    func unsetSystemError() {
        system.unsetError()
    }
}

//MARK: - Equatable

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system// &&
//        lhs.userData == rhs.userData
    }
}
