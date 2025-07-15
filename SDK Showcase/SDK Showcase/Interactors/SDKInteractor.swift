//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol SDKInteractor {
    var builder: ClientBuilder { get set }
    var userAuthenticatorOptionNames: [String] { get }

    /// Initializes the SDK, requires setting below methods
    /// - Parameter result: The result from the SDK
    func initializeSDK(result: @escaping SDKResult)
    /// Resets the SDK to the
    /// - Parameter result: The result from the SDK
    func resetSDK(result: @escaping SDKResult)
    
    func setConfigModel(_ model: SDKConfigModel)
    func setCertificates(_ certs: [String])
    func setPublicKey(_ key: String)
    func setAdditionalResourceUrls(_ url: [String])
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval)
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval)
    func setStoreCookies(_ storeCookies: Bool)
    
    func register(with provider: IdentityProvider)
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void)
    func changePin()
    
    func fetchUserProfiles()
    func authenticatorNamesForUser(_ userId: String) -> [String]
    func authenticateUser(optionName: String)
}

//MARK: - Real methods

class SDKInteractorReal: SDKInteractor {
    @ObservedObject var appState: AppState
    
    private static let staticBuilder = ClientBuilder()
    private var device: AppState.DeviceData { appState.deviceData }
    private var client: Client?
    private let userClient = SharedUserClient.instance
    
    var builder: ClientBuilder
    
    // TODO: rename or handle other way (remove formatCategoryName)
    var userAuthenticatorOptionNames: [String] {
        var toReturn = [String]()
        userClient.userProfiles.forEach { userProfile in
            let authenticators = authenticatorNamesForUser(userProfile.profileId)
            toReturn.append(contentsOf: authenticators.map { name in formatCategoryName(userId: userProfile.profileId, authenticatorName: name) })
        }
        return toReturn
    }
    
    func authenticatorNamesForUser(_ userId: String) -> [String] {
        // For now only registered authenticators
        return userClient.authenticators(.registered, for: ShowCaseProfile(profileId: userId)).map { $0.name }
    }

    init(appState: AppState, client: Client? = nil, builder: ClientBuilder = SDKInteractorReal.staticBuilder) {
        self.appState = appState
        self.client = client
        self.builder = builder
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        builder.buildAndWaitForProtectedData { client in
            client.start { error in
                if let error {
                    return result(.failure(error))
                } else {
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

    func register(with provider: IdentityProvider) {
        userClient.registerUserWith(identityProvider: provider, scopes: ["read", "openid", "email"], delegate: self)
    }
    
    func changePin() {
        guard userClient.authenticatedUserProfile != nil else {
            appState.setSystemError(string: "You must be authenticated to change your PIN.")
            return
        }
        userClient.changePin(delegate: self)
    }
    
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void) {
        userClient.validatePolicyCompliance(for: pin) { error in
            completion(error)
        }
    }
    
    func fetchUserProfiles() {
        let users = userClient.userProfiles.map { userProfile in
            let user = AppState.UserData()
            user.userId = userProfile.profileId
            return user
        }
        appState.system.registrationState = .registered(users)
    }
    
    func authenticateUser(optionName: String) {
        let unformatted = unformatCategoryName(optionName)
        guard let userProfile = userClient.userProfiles.first(where: { user in user.profileId == unformatted.0 }) else {
            fatalError("No user profile for option `\(optionName)`")
        }
        guard let authenticator = userClient.authenticators(.registered, for: userProfile).first(where: { user in user.name == unformatted.1 }) else {
            fatalError("No authenticator for option `\(optionName)`")
        }
        userClient.authenticateUserWith(profile: userProfile, authenticator: authenticator, delegate: self)
    }
}
//MARK: - UserProfile formatting
extension SDKInteractorReal {
    func formatCategoryName(userId: String, authenticatorName: String) -> String {
        return userId+"-"+authenticatorName
    }
    
    func unformatCategoryName(_ formattedName: String) -> (userId: String, authenticatorName: String) {
        let parts = formattedName.split(separator: "-")
        return (String(parts[0]), String(parts[1]))
    }
}

//MARK: - ChangePinDelegate
extension SDKInteractorReal: ChangePinDelegate {
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceivePinChallenge challenge: any OneginiSDKiOS.PinChallenge) {
        pinPadInteractor.setPinChallenge(challenge)
        if let _ = challenge.error {
            appState.setSystemError(string: "Wrong previous PIN, please try again (\(challenge.remainingFailureCount))")
            return
        }
        
        pinPadInteractor.showPinPad(for: .changing)
    }
    
    func userClient(_ userClient: any UserClient, didChangePinForUser profile: any UserProfile) {
        pinPadInteractor.didChangePinForUser()
    }

    func userClient(_ userClient: any UserClient, didFailToChangePinForUser profile: any UserProfile, error: any Error) {
        appState.setSystemError(string: error.localizedDescription)
    }
}

//MARK: - RegistrationDelegate
extension SDKInteractorReal: RegistrationDelegate {
    
    func userClient(_ userClient: any OneginiSDKiOS.UserClient, didReceiveCreatePinChallenge challenge: any OneginiSDKiOS.CreatePinChallenge) {
        if let error = challenge.error {
            pinPadInteractor.setCreatePinChallenge(challenge)
            pinPadInteractor.showError(error)
            return
        }
        switch appState.system.pinPadState {
        case .changing:
            appState.system.pinPadState = .hidden
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self else { return }
                self.pinPadInteractor.setCreatePinChallenge(challenge)
                self.pinPadInteractor.showPinPad(for: .creating)
            }
        default:
            browserInteractor.didReceiveCreatePinChallenge(challenge)
        }
    }

    func userClient(_ userClient: any UserClient, didRegisterUser profile: any UserProfile, with identityProvider: any IdentityProvider, info: (any CustomInfo)?) {
        browserInteractor.didRegisterUser(profileId: profile.profileId)
    }
    
    func userClient(_ userClient: any UserClient, didReceiveBrowserRegistrationChallenge challenge: any BrowserRegistrationChallenge) {
        browserInteractor.didReceiveBrowserRegistrationChallenge(challenge)
    }
    
    func userClient(_ userClient: any UserClient, didFailToRegisterUserWith identityProvider: any IdentityProvider, error: any Error) {
        browserInteractor.didFailToRegisterUser(with: error)
    }
}

//MARK: - AuthenticationDelegate (apart from didReceivePinChallenge)
extension SDKInteractorReal: AuthenticationDelegate {
    func userClient(_ userClient: UserClient, didReceiveCustomAuthFinishAuthenticationChallenge challenge: CustomAuthFinishAuthenticationChallenge) {
        // not needed for pin authenticator
        appState.setSystemError(string: "didReceiveCustomAuthFinishAuthenticationChallenge not handled yet")
    }
    
    func userClient(_ userClient: UserClient, didAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, info customAuthInfo: CustomInfo?) {
        appState.unsetSystemError()
        appState.system.authenticationState = .authenticated(userProfile.profileId)
        appState.system.pinPadState = .hidden
    }
    
    func userClient(_ userClient: UserClient, didFailToAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, error: Error) {
        // TODO: don't we want to use ErrorMapper from old ExampleApp?
        appState.setSystemError(string: "Authentication failed")
    }
}

//MARK: - Private Protocol Extension
private extension SDKInteractor {
    var browserInteractor: BrowserRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.browserInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }

    
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        return ConfigModel(dictionary: model.dictionary)
    }
}
