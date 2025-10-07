//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import UIKit
import OneginiSDKiOS

//MARK: - Protocol
protocol PushNotitificationsInteractor {
    func registerForPushNotifications()

    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error)
    func updateBadge(_ value: Int?)
}

//MARK: - Real methods
class PushNotitificationsInteractorReal: NSObject, PushNotitificationsInteractor {
    @Injected var appState: AppState
    private var completion: ((_ token: Data?, _ error: Error?) -> Void)?
    private let userClient = SharedUserClient.instance

    func registerForPushNotifications() {
        guard mobileAuthRequestInteractor.isMobileAuthEnrolled else {
            appState.setSystemInfo(string: "You are not enrolled for mobile authentication. Please enroll first!")
            return
        }
        registerForPushNotifications { [self] (token, error) in
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
    
    func registerForPushNotifications(completion: @escaping (_ token: Data?, _ error: Error?) -> Void) {
        self.completion = completion
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [self] (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                appState.setSystemInfo(string: "Permission for push notifications denied.")
            }
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        completion?(deviceToken, nil)
        self.completion = nil
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
        completion?(nil, error)
        self.completion = nil
    }
    
    func updateBadge(_ value: Int?) {
        UNUserNotificationCenter.current().setBadgeCount(value ?? appState.pendingTransactions.count)
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension PushNotitificationsInteractorReal: UNUserNotificationCenterDelegate {
    private var mobileAuthRequestInteractor: MobileAuthRequestInteractor {
        @Injected var interactors: Interactors
        return interactors.mobileAuthRequestInteractor
    }
    
    // Called when the app is in the background or was killed and woken up by a push or an interaction with the banner
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        mobileAuthRequestInteractor.handlePushMobileAuthenticationRequest(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    // Called when the app is in the foreground, just shows the banner and play sound. The interaction with the banner is performed above
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
    }
}
