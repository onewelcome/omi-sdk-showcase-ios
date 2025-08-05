//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import UIKit

//MARK: - Protocol
protocol PushNotitificationsInteractor {
    func registerForPushNotifications(completion: @escaping (_ token: Data?, _ error: Error?) -> Void)
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error)
}

//MARK: - Real methods
class PushNotitificationsInteractorReal: NSObject, PushNotitificationsInteractor {
    @Injected var appState: AppState
    private var completion: ((_ token: Data?, _ error: Error?) -> Void)?
    
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
}

//MARK: - UNUserNotificationCenterDelegate
extension PushNotitificationsInteractorReal: UNUserNotificationCenterDelegate {
    private var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    // Called when the app is in the background or was killed and woken up by a push
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let mappedCompletionHandler: (UNNotificationPresentationOptions) -> Void = { _ in completionHandler() }
        sdkInteractor.handlePushMobileAuthenticationRequest(userInfo: response.notification.request.content.userInfo, completionHandler: mappedCompletionHandler)
    }
    
    // Called when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        sdkInteractor.handlePushMobileAuthenticationRequest(userInfo: notification.request.content.userInfo, completionHandler: completionHandler)
    }
}
