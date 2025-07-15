//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class AppState: ObservableObject {
    @Published var system = System()
    @Published var deviceData = DeviceData()
    @Published var registeredUsers = [UserData]()
    
    func reset() {
        system.reset()
        deviceData.reset()
        resetRegisteredUsers()
    }
    
    func setSystemError(string: String) {
        system.setError(string)
    }
    
    func unsetSystemError() {
        system.unsetError()
    }
    
    func resetRegisteredUsers() {
        registeredUsers.removeAll()
    }
    
    func addRegisteredUser(_ newUser: UserData) {
        system.registrationState = .registered
        registeredUsers.removeAll { user in
            user.userId == newUser.userId
        }
        registeredUsers.append(newUser)
    }
}

//MARK: - Equatable

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system &&
        lhs.registeredUsers == rhs.registeredUsers
    }
}
