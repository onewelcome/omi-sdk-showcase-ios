//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

//MARK: - Actions for Options
extension ContentView {
    func setBuilder() {
        sdkInteractor.setConfigModel(SDKConfigModel.default)
        sdkInteractor.setPublicKey(value(for: "setPublicKey"))
        sdkInteractor.setCertificates([value(for: "setX509PEMCertificates")])
        sdkInteractor.setAdditionalResourceUrls([value(for: "setAdditionalResourceURL")])
        sdkInteractor.setStoreCookies(value(for: "setStoreCookies"))
        sdkInteractor.setHttpRequestTimeout(value(for: "setHttpRequestTimeout"))
        sdkInteractor.setDeviceConfigCacheDuration(value(for: "setDeviceConfigCacheDuration"))
    }
    
    func initializeSDK(automatically: Bool) {
        UserDefaults.standard.set(automatically, forKey: "autoinitialize")
        errorValue.removeAll()
        /// You can comment the below line if the app is configured with the configurator and do have OneginiConfigModel set.
        setBuilder()
        sdkInteractor.initializeSDK { result in
            switch result {
            case .success:
                system.unsetInfo()
                system.isSDKInitialized = true
                sdkInteractor.fetchUserProfiles()
                sdkInteractor.fetchEnrollment()
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setInfo(errorValue)
                system.isSDKInitialized = false
            }
            system.isProcessing = false
        }
    }
    
    func resetSDK() {
        errorValue.removeAll()
        setBuilder()
        sdkInteractor.resetSDK { result in
            switch result {
            case .success:
                system.unsetInfo()
                system.isSDKInitialized = false
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setInfo(errorValue)
                system.isSDKInitialized = false
            }
            system.isProcessing = false
        }
    }
    
    func changePIN() {
        pinPadInteractor.changePin()
    }
    
    func enrollForMobileAuthentication() {
        sdkInteractor.enrollForMobileAuthentication()
    }
    
    func registerForPushes() {
        sdkInteractor.registerForPushNotifications()
    }
    
    func registerAuthenticator() {
        if case .authenticated = system.userState {
            selectedOption = nil
            showConfirmationDialog = true
        } else {
            appstate.setSystemInfo(string: "You must be authenticated to perform this action.")
        }
        system.isProcessing = false
    }
    
    func updateMobileAuthenticationCategorySelection() {
        guard category.type == .mobileAuthentication, appstate.system.enrollmentState != EnrollmentState.unenrolled else { return }
        category.selection = [Selection(name: Selections.loginWithOtp.rawValue)]
    }
    
    func updateIdentityProviders() {
        guard category.type == .userRegistation else { return }
        category.selection = authenticatorInteractor.fetchIdentityProviders().map { Selection(name: $0.name, type: .register) }
    }
    
    func updateUsersSelection() {
        guard category.type == .userAuthentication else { return }
        category.selection = sdkInteractor.userAuthenticatorOptionNames.map { Selection(name: $0, type: .authenticate, logo: "person.crop.circle") }
    }
    
    func updateLogout() {
        guard category.type == .userLogout else { return }
        let userId = appstate.system.userState.userId
        category.selection = sdkInteractor.userAuthenticatorOptionNames.filter { $0 == userId }.map { Selection(name: $0, type: .logout, logo: "person.crop.circle") }
    }
    
    func updateDeregister() {
        guard category.type == .userDeregistation else { return }
        category.selection = sdkInteractor.userAuthenticatorOptionNames.map { Selection(name: $0, type: .deregister, logo: "person.crop.circle") }
    }
    
    func pendingTransactionsTask() {
        guard category.type == .pendingTransactions else { return }
        Task {
            let pendingTransactions = await mobileAuthRequestInteractor.fetchPendingTransactionNames()
            category.selection = pendingTransactions.map { Selection(name: $0, type: .pending, logo: "doc.badge.clock") }
        }
    }
}

//MARK: - Actions for Selections
extension ContentView {
    
    func startRegistration(authenticatorName: String? = nil) {
        registrationInteractor.setStateless(value(for: "Stateless"))
        registrationInteractor.register(with: authenticatorName)
    }

    func cancelRegistration() {
        registrationInteractor.cancelRegistration()
        system.isProcessing = false
    }

    func handlePending(transacationId: String) {
        mobileAuthRequestInteractor.handlePendingTransaction(id: transacationId)
    }
}
    
//MARK: - Helpers
extension ContentView {
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var mobileAuthRequestInteractor: MobileAuthRequestInteractor {
        @Injected var interactors: Interactors
        return interactors.mobileAuthRequestInteractor
    }
    
    var authenticatorInteractor: AuthenticatorInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorInteractor
    }
    
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    
    var registrationInteractor: RegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.registrationInteractor
    }
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }

    var initializationStatus: String {
        system.isSDKInitialized ? "✅ SDK initialized" : "❌ SDK not initialized \(errorValue)"
    }
    
    var userStateDescription: String {
        switch system.userState {
        case .notRegistered:
            "🚫 No user registered"
        case .registering:
            "⏳ Registration in progress..."
        case .registered, .unauthenticated:
            "👥 \(sdkInteractor.numberOfRegisteredUsers) registered users"
        case .authenticated(let userId):
            "👤 User authenticated as \(userId)"
        case .stateless:
            "🤖 Stateless user authenticated"
        }
    }
    
    var enrollmentStateDescription: String {
        switch system.enrollmentState {
        case .unenrolled:
            "⚠️ User not enrolled for mobile authentication"
        case .mobile:
            "📲 User enrolled for mobile authentication"
        case .push:
            "📳 User enrolled for push notifications"
        }
    }
    
    func binding(for action: Action) -> Binding<Action> {
        setDefaultValueIfNeeded(for: action)
        return .init(
            get: {
                return actions.first { $0 == action } ?? action
            },
            set: { newAction in
                actions.removeAll { $0 == action }
                actions.append(newAction)
            }
        )
    }
    
    func setDefaultValueIfNeeded(for action: Action) {
        DispatchQueue.main.async {
            if !actions.contains(action) {
                actions.append(action)
            }
        }
    }
    
    func value<T>(for key: String) -> T {
        guard let action = actions.first(where: { $0.name == key }),
            let value = action.providedValue ?? action.defaultValue else {
            return [] as? T
            ?? String() as? T
            ?? Int() as? T
            ?? Double() as? T
            ?? Bool() as! T
        }
        
        guard let cast = value as? T else {
            switch T.self {
            case is Int.Type:
                return Int(value as! String) as! T
            case is Double.Type:
                return Double(value as! String) as! T
            default:
                fatalError("Unsupported type \(type(of: value))")
            }
        }

        return cast
    }
}
