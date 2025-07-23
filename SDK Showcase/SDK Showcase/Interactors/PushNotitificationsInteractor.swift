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
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //TODO: Handle in next PR
        completionHandler()
    }
}
