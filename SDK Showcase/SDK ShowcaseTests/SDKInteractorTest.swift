//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Testing
@testable import SDK_Showcase
import OneginiSDKiOS

class SDKInteractorTest {
    let appState = AppState()
    static let sdkResult = { (result: SDKResult) in
        result(.success)
    }
    var builder = ClientBuilder()
    var interactor: SDKInteractor

    init() {
        interactor = SDKInteractorReal(appState: appState)
        interactor.builder = builder
        interactor.setStoreCookies(true)
        interactor.setConfigModel(SDKConfigModel.default)
        interactor.setCertificates(["Cert1", "Cert2"])
        interactor.setPublicKey("key")
    }
    
    deinit {
        appState.reset()
    }

    @Test
    func initializeSDK() {
        interactor.initializeSDK { result in
            #expect(self.appState.system.isSDKInitialized == true)
        }
    }
    
    @Test
    func resetSDK() {
        interactor.resetSDK { result in
            #expect(self.appState.system.isSDKInitialized == false)
        }
    }

}
