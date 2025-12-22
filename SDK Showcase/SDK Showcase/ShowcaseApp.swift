//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class ShowcaseApp: ObservableObject {
    @Published var system = System()
    @Published var routing = ViewRouting()
    @Published var deviceData = DeviceData()
    @Published var registeredUsers = Set<UserData>()
    @Published var pendingTransactions = Set<PendingMobileAuthRequestEntity>()
    private var pushInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
    
    private var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }

    func reset() {
        system.reset()
        deviceData.reset()
        resetRegisteredUsers()
        pendingTransactions.removeAll()
        routing.backHome()
        system.autoinitializeSDK = false
        pushInteractor.updateBadge(0)
    }
    
    func remove(profileId: String) {
        let authenticators = authenticatorRegistrationInteractor.authenticatorNames(for: profileId)
        let userData = ShowcaseApp.UserData(userId: profileId, authenticatorsNames: authenticators)
        registeredUsers.remove(userData)
        system.setUserState(.unauthenticated)
        pendingTransactions.removeAll()
        pushInteractor.updateBadge(0)
    }
    
    func removePendingTransaction(transactionId: String) {
        guard let toRemove = pendingTransactions.first(where: { $0.pendingTransaction?.transactionId == transactionId }) else { return }
        pendingTransactions.remove(toRemove)
    }
    
    func setSystemInfo(string: String) {
        system.isProcessing = false
        system.setInfo(string)
    }

    func unsetSystemInfo() {
        system.unsetInfo()
    }
    
    func resetRegisteredUsers() {
        registeredUsers.removeAll()
    }
    
    func addRegisteredUser(_ newUser: UserData, authenticate: Bool = false) {
        system.setUserState(newUser.isStateless ? .stateless : (authenticate ? .authenticated(newUser.userId) : .registered))
        registeredUsers.insert(newUser)
    }
}

//MARK: - Equatable

extension ShowcaseApp: Equatable {
    static func == (lhs: ShowcaseApp, rhs: ShowcaseApp) -> Bool {
        lhs.system == rhs.system &&
        lhs.registeredUsers == rhs.registeredUsers
    }
}
