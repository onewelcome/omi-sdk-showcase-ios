//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol SDKInteractor {
    var builder: ClientBuilder { get set }
    var userAuthenticatorOptionNames: [String] { get }
    var numberOfRegisteredUsers: Int { get }

    func initializeSDK(result: @escaping SDKResult)
    func resetSDK(result: @escaping SDKResult)
    
    func setConfigModel(_ model: SDKConfigModel)
    func setCertificates(_ certs: [String])
    func setPublicKey(_ key: String)
    func setAdditionalResourceUrls(_ url: [String])
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval)
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval)
    func setStoreCookies(_ storeCookies: Bool)
 
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void)
    func logout(optionName: String)
    func deregister(optionName: String)
        
    func enrollForMobileAuthentication()
    func registerForPushNotifications()
    
    func fetchUserProfiles()
    func fetchEnrollment()
}

//MARK: - Real methods

class SDKInteractorReal: SDKInteractor {
    @ObservedObject var appState: AppState

    private static let staticBuilder = ClientBuilder()
    private var device: AppState.DeviceData { appState.deviceData }
    private var client: Client?
    private let userClient = SharedUserClient.instance
    var builder: ClientBuilder
    
    var userAuthenticatorOptionNames: [String] {
        return appState.registeredUsers.map { $0.userId }
    }
    
    var numberOfRegisteredUsers: Int {
        return appState.registeredUsers.filter { $0.isStateless == false }.map { $0.userId }.count
    }

    init(appState: AppState, client: Client? = nil, builder: ClientBuilder = SDKInteractorReal.staticBuilder) {
        self.appState = appState
        self.client = client
        self.builder = builder
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        builder.buildAndWaitForProtectedData { client in
            client.start { [self] error in
                if let error {
                    return result(.failure(error))
                } else {
                    appState.routing.backHome()
                    return result(.success)
                }
            }
        }
    }
    
    func resetSDK(result: @escaping SDKResult) {
        builder.buildAndWaitForProtectedData { client in
            client.reset { [self] error in
                if let error {
                    return result(.failure(error))
                } else {
                    clearDeviceData()
                    return result(.success)
                }
            }
        }
    }

    func setPublicKey(_ key: String) {
        device.publicKey = key
        builder.setServerPublicKey(key)
    }
    
    func setConfigModel(_ model: SDKConfigModel) {
        device.model = model
        let mappedModel = mapSDKConfigModel(model)
        _ = builder.setConfigModel(mappedModel)
    }
    func setCertificates(_ certs: [String]) {
        device.certs = certs
        _ = builder.setX509PEMCertificates(certs)
    }
    
    func setAdditionalResourceUrls(_ url: [String]) {
        _ = builder.setAdditionalResourceUrls(url)
    }
    
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval) {
        _ = builder.setDeviceConfigCacheDuration(cacheDuration)
    }
    
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval) {
        _ = builder.setHttpRequestTimeout(requestTimeout)
    }
    
    func setStoreCookies(_ storeCookies: Bool) {
        _ = builder.setStoreCookies(storeCookies)
    }

    func clearDeviceData() {
        appState.reset()
    }

    func logout(optionName: String) {
        userClient.logoutUser { [self] profile, error in
            if profile != nil {
                appState.system.setUserState(.unauthenticated)
                appState.setSystemInfo(string: "Profile \(optionName) has been logged out.")
            } else {
                appState.setSystemInfo(string: "Logout failed. The profile is not authenticated most likely.")
            }
        }
    }
    
    func deregister(optionName: String) {
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == optionName }) else {
            if optionName == UserState.stateless.rawValue {
                appState.setSystemInfo(string: "Deregistration cannot be performed for the stateless user.")
            } else {
                appState.setSystemInfo(string: "Deregistration failed. The profile has been already unregistered.")
            }
            return
        }
        userClient.deregister(user: userProfile) { [self] error in
            if error != nil {
                appState.setSystemInfo(string: "Deregistration failed. The profile has not been found.")
            } else {
                appState.remove(profileId: userProfile.profileId)
                appState.setSystemInfo(string: "Profile \(optionName) has been deregister.")
            }
        }
    }
    
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void) {
        userClient.validatePolicyCompliance(for: pin) { error in
            completion(error)
        }
    }
    
    func fetchUserProfiles() {
        appState.resetRegisteredUsers()
        userClient.userProfiles
            .map { AppState.UserData(userId: $0.profileId, authenticatorsNames: authenticatorRegistrationInteractor.authenticatorNames(for: $0.profileId)) }
            .forEach { appState.addRegisteredUser($0) }
    }
    
    func fetchEnrollment() {
        if isMobileAuthEnrolled {
            appState.system.setEnrollmentState(.mobile)
        }
        if isPushRegistered {
            appState.system.setEnrollmentState(.push)
        }
    }

    func enrollForMobileAuthentication() {
        guard precheck() else { return }
        userClient.enrollMobileAuth { [self] error in
            appState.system.isProcessing = false
            if let error {
                appState.setSystemInfo(string: error.localizedDescription)
            } else {
                appState.system.setEnrollmentState(.mobile)
                appState.setSystemInfo(string: "User successfully enrolled for mobile authentication!")
            }
        }
    }

    func registerForPushNotifications() {
        guard precheck() else { return }
        guard isMobileAuthEnrolled else {
            appState.setSystemInfo(string: "You are not enrolled for mobile authentication. Please enroll first!")
            return
        }
        pushInteractor.registerForPushNotifications { [self] (token, error) in
            guard let token else {
                appState.setSystemInfo(string: error?.localizedDescription ?? "Failed to register for push notifications.")
                return
            }
            userClient.enrollPushMobileAuth(with: token) { [self] error in
                appState.system.isProcessing = false
                if let error {
                    appState.setSystemInfo(string: error.localizedDescription)
                } else {
                    appState.system.setEnrollmentState(.push)
                    let token = token.map { String(format: "%02.2hhx", $0) }.joined()
                    print("token=\(token)")
                    appState.setSystemInfo(string: "User successfully registed for push notifications!\n\nToken: \(token)")
                }
            }
        }
    }

}

//MARK: -  Protocol Extension
extension SDKInteractorReal {
    
    var registrationInteractor: RegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.registrationInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var pushInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
    
    var authenticatorRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
}

//MARK: - Private Protocol Extension
private extension SDKInteractorReal {

    var isMobileAuthEnrolled: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isMobileAuthEnrolled(for: ProfileProxy(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    var isPushRegistered: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: ProfileProxy(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    func precheck() -> Bool {
        let stateless = userClient.isStateless && userClient.accessToken != nil
        let check = userClient.authenticatedUserProfile != nil
        
        guard !stateless else {
            appState.setSystemInfo(string: "Stateless user cannot proceed.")
            appState.system.isProcessing = false
            return false
        }
        
        if !check {
            appState.setSystemInfo(string: "You must be authenticated first.")
            appState.system.isProcessing = false
        }
        
        return check
    }
    
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        return ConfigModel(dictionary: model.dictionary)
    }

}
