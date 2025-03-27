//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol
protocol SDKInteractor {
    func initializeSDK(result: @escaping SDKResult)
}

//MARK: - Stubb methods
struct StubSDKInteractor: SDKInteractor {
    func initializeSDK(result: @escaping SDKResult) {
        return result(.success)
    }
}

//MARK: - Real methods
struct RealSDKInteractor: SDKInteractor {
    func initializeSDK(result: @escaping SDKResult) {
        SharedClient.instance.start { e in
            if let e {
                return result(.failure(e))
            } else {
                return result(.success)
            }
        }
    }
}
