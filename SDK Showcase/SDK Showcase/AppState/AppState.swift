//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class AppState: ObservableObject {
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    @Published var system = System()
    @Published var routing = ViewRouting()
    @Published var deviceData = DeviceData()
    @Published var registeredUsers = Set<UserData>()
    @Published var pendingTransactions = Set<PendingMobileAuthRequestEntity>()
    
    func reset() {
        system.reset()
        deviceData.reset()
        resetRegisteredUsers()
        pendingTransactions.removeAll()
    }
    
    func remove(profileId: String) {
        let authenticators = authenticatorRegistrationInteractor.authenticatorNames(for: profileId)
        let userData = AppState.UserData(userId: profileId, authenticatorsNames: authenticators)
        registeredUsers.remove(userData)
        system.setUserState(.unauthenticated)
    }
    
    func setSystemInfo(string: String) {
        system.setInfo(string)
    }

    func unsetSystemInfo() {
        system.unsetInfo()
    }
    
    func resetRegisteredUsers() {
        registeredUsers.removeAll()
    }
    
    func addRegisteredUser(_ newUser: UserData) {
        system.setUserState(newUser.isStateless ? .stateless : .authenticated(newUser.userId))
        registeredUsers.insert(newUser)
    }
}

//MARK: - Equatable

extension AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        lhs.system == rhs.system &&
        lhs.registeredUsers == rhs.registeredUsers
    }
}
