//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol SDKInteractor {
    var builder: ClientBuilder { get set }
    var userAuthenticatorOptionNames: [String] { get }
    var shouldEnableLoginWithOTPSelection: Bool { get }
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
    
    func enrollForMobileAuthentication()
    func registerForPushNotifications()
    
    func fetchUserProfiles()
    func fetchEnrollment()
    func authenticatorNames(for userId: String) -> [String]
    func authenticateUser(optionName: String)
    
    func handleOtp(_ code: String)
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
        var toReturn = [String]()
        appState.registeredUsers
            .forEach { userData in
                userData.authenticatorsNames.forEach { authenticatorName in
                    toReturn.append(formatCategoryName(userId: userData.userId, authenticatorName: authenticatorName))
                }
            }
        return toReturn
    }
    
    var shouldEnableLoginWithOTPSelection: Bool {
        let isAuthenticated = appState.system.userState.userId != nil
        let isEnrolled = appState.system.enrollmentState != EnrollmentState.unenrolled
        return isAuthenticated && isEnrolled
    }
    
    func authenticatorNames(for userId: String) -> [String] {
        // For now only registered authenticators
        return userClient.authenticators(.registered, for: ShowcaseProfile(profileId: userId)).map { $0.name }
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
        precheck()
        userClient.changePin(delegate: self)
    }
    
    func validatePolicy(for pin: String, completion: @escaping (Error?) -> Void) {
        userClient.validatePolicyCompliance(for: pin) { error in
            completion(error)
        }
    }
    
    func fetchUserProfiles() {
        appState.resetRegisteredUsers()
        userClient.userProfiles
            .map { AppState.UserData(userId: $0.profileId, authenticatorsNames: authenticatorNames(for: $0.profileId)) }
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
    
    
    func enrollForMobileAuthentication() {
        precheck()
        userClient.enrollMobileAuth { [self] error in
            if let error {
                appState.setSystemInfo(string: error.localizedDescription)
            } else {
                appState.system.setEnrollmentState(.mobile)
                appState.setSystemInfo(string: "User successfully enrolled for mobile authentication!")
            }
        }
    }
    
    func registerForPushNotifications() {
        precheck()
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
                if let error {
                    appState.setSystemInfo(string: error.localizedDescription)
                } else {
                    appState.system.setEnrollmentState(.push)
                    let token = token.map { String(format: "%02.2hhx", $0) }.joined()
                    appState.setSystemInfo(string: "User successfully registed for push notifications!\n\nToken: \(token)")
                }
            }
        }
    }
    
    func handleOtp(_ code: String) {
        guard userClient.canHandleOTPMobileAuthRequest(otp: code) else {
            appState.setSystemInfo(string: "Invalid otp code or previous request in progress.")
            return
        }
        userClient.handleOTPMobileAuthRequest(otp: code, delegate: self)
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
            appState.setSystemInfo(string: "Wrong previous PIN, please try again (\(challenge.remainingFailureCount))")
            return
        }
        
        pinPadInteractor.showPinPad(for: .changing)
    }
    
    func userClient(_ userClient: any UserClient, didChangePinForUser profile: any UserProfile) {
        pinPadInteractor.didChangePinForUser()
    }

    func userClient(_ userClient: any UserClient, didFailToChangePinForUser profile: any UserProfile, error: any Error) {
        appState.setSystemInfo(string: error.localizedDescription)
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
            appState.system.setPinPadState(.hidden)
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
        appState.setSystemInfo(string: "didReceiveCustomAuthFinishAuthenticationChallenge not handled yet")
    }
    
    func userClient(_ userClient: UserClient, didAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, info customAuthInfo: CustomInfo?) {
        appState.unsetSystemInfo()
        appState.system.setUserState(.authenticated(userProfile.profileId))
        appState.system.setPinPadState(.hidden)
        fetchEnrollment()
    }
    
    func userClient(_ userClient: UserClient, didFailToAuthenticateUser userProfile: UserProfile, authenticator: Authenticator, error: Error) {
        appState.setSystemInfo(string: "Authentication failed")
        if (error as NSError).code == 9003 {
            // User account deregistered (too many wrong PIN attempts)
            appState.registeredUsers.remove(AppState.UserData(userId: userProfile.profileId, authenticatorsNames: authenticatorNames(for: userProfile.profileId)))
            pinPadInteractor.showPinPad(for: .hidden)
        }
    }
}

//MARK: - MobileAuthRequestDelegate
extension SDKInteractorReal: MobileAuthRequestDelegate {
    func userClient(_ userClient: UserClient, didReceiveConfirmation confirmation: @escaping (Bool) -> Void, for request: MobileAuthRequest) {
        // Now we can ask the user to confirm or deny the request.
        // For Showcase App we confirm it right away (at least for otp)
        confirmation(true)
    }
    func userClient(_ userClient: UserClient, didFailToHandleOTPMobileAuthRequest otp: String, error: any Error) {
        appState.setSystemInfo(string: error.localizedDescription)
    }

    func userClient(_ userClient: UserClient, didHandleRequest request: MobileAuthRequest, authenticator: Authenticator?, info customAuthenticatorInfo: CustomInfo?) {
        appState.setSystemInfo(string: "The transaction has been confirmed successfully.")
    }
}

//MARK: - Private Protocol Extension
private extension SDKInteractorReal {
    var browserInteractor: BrowserRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.browserInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var pushInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }

    var isMobileAuthEnrolled: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isMobileAuthEnrolled(for: ShowcaseProfile(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    var isPushRegistered: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: ShowcaseProfile(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    func precheck() {
        if userClient.authenticatedUserProfile == nil {
            appState.setSystemInfo(string: "You must be authenticated first.")
        }
    }
    
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        return ConfigModel(dictionary: model.dictionary)
    }
}
