//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var interactor: PushNotitificationsInteractor {
        @Injected var interactors: Interactors
        return interactors.pushInteractor
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        interactor.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        interactor.didFailToRegisterForRemoteNotificationsWithError(error)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = interactor as! PushNotitificationsInteractorReal
        return true
    }
}
