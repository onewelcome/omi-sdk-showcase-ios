//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

protocol MobileAuthRequestInteractor {
    func handlePushMobileAuthenticationRequest(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void)
    func handleOtp(_ code: String)
    func handlePendingTransaction(id: String)
    func fetchPendingTransactionNames() async -> [String]
    func fetchEnrollment()
    func enrollForMobileAuthentication()

    var isMobileAuthEnrolled: Bool { get }
}

class MobileAuthRequestInteractorReal: MobileAuthRequestInteractor {
    private let userClient = SharedUserClient.instance
    @ObservedObject var appState: AppState

    init(appState: AppState) {
        self.appState = appState
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

    func fetchEnrollment() {
        if isMobileAuthEnrolled {
            appState.system.setEnrollmentState(.mobile)
        }
        if isPushRegistered {
            appState.system.setEnrollmentState(.push)
        }
    }
    
    func fetchPendingTransactionNames() async -> [String] {
        guard precheck() else { return [] }
        guard isMobileAuthEnrolled else {
            appState.setSystemInfo(string: "You are not enrolled for mobile authentication. Please enroll first!")
            return []
        }
        appState.system.isProcessing = true

        return await withCheckedContinuation { continuation in
            userClient.pendingPushMobileAuthRequests { [self] requests, error in
                appState.system.isProcessing = false
                guard let requests else {
                    pushInteractor.updateBadge(0)
                    continuation.resume(returning: [])
                    return
                }
                for request in requests {
                    appState.pendingTransactions.insert(PendingMobileAuthRequestEntity(pendingTransaction: request))
                }
                let requestsToReturn = requests.compactMap(\.transactionId)
                continuation.resume(returning: requestsToReturn)
                pushInteractor.updateBadge(requestsToReturn.count)
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
    
    func handlePushMobileAuthenticationRequest(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        print("push: \(userInfo)")
        guard let pendingTransaction = userClient.pendingMobileAuthRequest(from: userInfo) else {
            appState.setSystemInfo(string: "Push notification not handled. User is not authenticated most likely.")
            completionHandler()
            return
        }
        
        let mobileAuthRequest = PendingMobileAuthRequestEntity(pendingTransaction: pendingTransaction, delegate: self)
        appState.pendingTransactions.insert(mobileAuthRequest)
        appState.routing.navigate(to: .pendingTransactions)
        completionHandler()
    }
    
    func handlePendingTransaction(id: String) {
        guard let transaction = pendingTransaction(id: id),
              let pendingRequestProxy = transaction.pendingTransaction else {
            return
        }
        
        appState.system.isProcessing = true
        userClient.handlePendingMobileAuthRequest(pendingRequestProxy, delegate: self)
    }
    
    func confirmTransaction(for entity: MobileAuthRequestEntity, automatically: Bool) {
        appState.system.isProcessing = false
        if automatically {
            if let transaction = pendingTransaction(id: entity.transactionId!) {
                entity.confirmation?(true) // TODO: after that isMobileAuthEnrolled changes from true to false
                appState.pendingTransactions.remove(transaction)
                appState.setSystemInfo(string: "Transaction with message \(entity.message ?? "") confirmed")
                pushInteractor.updateBadge(nil)
            }
        } else {
            //TODO: For now transaction is confirmed automatically. This would change in next PR's.
            //We need to show a confirmation dialog for PIN/Biometric/Finger etc...
        }
    }
    
    func pendingTransaction(id: String) -> PendingMobileAuthRequestEntity? {
         appState.pendingTransactions.first { $0.pendingTransaction?.transactionId == id }
    }
    
    var isMobileAuthEnrolled: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isMobileAuthEnrolled(for: UserProfileImplementation(profileId: profileId)) else {
            return false
        }
        
        return true
    }
    
    var isPushRegistered: Bool {
        guard let profileId = appState.system.userState.userId,
              userClient.isPushMobileAuthEnrolled(for: UserProfileImplementation(profileId: profileId)) else {
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
}

private extension MobileAuthRequestInteractorReal {
    var qrScannerInteractor: QRScannerInteractor {
        @Injected var interactors: Interactors
        return interactors.qrScannerInteractor
    }
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
    
    var pushInteractor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
}
    
extension MobileAuthRequestInteractorReal: MobileAuthRequestDelegate {
    func userClient(_ userClient: UserClient, didReceiveConfirmation confirmation: @escaping (Bool) -> Void, for request: MobileAuthRequest) {
        let mobileAuthEntity = MobileAuthRequestEntity()
        mobileAuthEntity.message = request.message
        mobileAuthEntity.transactionId = request.transactionId
        mobileAuthEntity.userProfile = request.userProfile
        mobileAuthEntity.authenticatorType = .confirmation
        mobileAuthEntity.confirmation = confirmation
        
        confirmTransaction(for: mobileAuthEntity, automatically: true)
        appState.system.isProcessing = false
    }

    func userClient(_ userClient: any UserClient, didFailToHandleRequest request: any MobileAuthRequest, authenticator: Authenticator?, error: any Error) {
        // it is original error
        print((error as NSError).userInfo)
        do {
            let params = ["authenticated" : "true",
                          "token" : "C8035E15B835A043FF8958E0086B1B31C730BD97A181D7E390789334DF86A7ACDDD31CA3359F2EC237ACF1B8E4F4C9121F086D3FB116D169B27CB039413A1A1A"]
            let profile = UserProfileImplementation(profileId: appState.system.userState.userId!)
            let encryptedParameters = try MobileAuthenticationCryptor().encryptAnswerParameters(params,
                                                                                                profile: profile)
            print(encryptedParameters)
            
//            let ongEncryptedParameters = try ONGMobileAuthenticationCryptor().encryptAnswerParameters(params, profile:  ONGUserProfile(id: profile.profileId))
//            print(ongEncryptedParameters)
            
            
        } catch {
            print(error)
        }
        appState.setSystemInfo(string: error.localizedDescription)
        pushInteractor.updateBadge(nil)
        appState.system.isProcessing = false
    }
}
