//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

//MARK: - Protocol
protocol PushNotitificationsInteractor {
    func registerForPushNotifications(completion: @escaping (_ token: String)->Void)
    
}

//MARK: - Real methods
class PushNotitificationsInteractorReal: PushNotitificationsInteractor {
    @Injected var appState: AppState

    func registerForPushNotifications(completion: @escaping (_ token: String)->Void) {
        //TODO: fill in the proper one in the next story
        completion("token")
    }
}
