//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol
protocol SDKInteractor {
    func initializeSDK(result: @escaping SDKResult)
}

//MARK: - Real methods
struct SDKInteractorReal: SDKInteractor {
    func initializeSDK(result: @escaping SDKResult) {
        SharedClient.instance.start { error in
            if let error {
                return result(.failure(error))
            } else {
                return result(.success)
            }
        }
    }
}

//MARK: - Stubbed methods
struct SDKInteractorStub: SDKInteractor {
    func initializeSDK(result: @escaping SDKResult) {
        return result(.success)
    }
}
