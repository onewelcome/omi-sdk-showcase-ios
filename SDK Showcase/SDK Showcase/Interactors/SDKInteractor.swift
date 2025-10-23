//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol the SDK interacts with
protocol SDKInteractor {
    var builder: ClientBuilder { get set }

    func initializeSDK(result: @escaping SDKResult)
    func resetSDK(result: @escaping SDKResult)
    
    func setConfigModel(_ model: SDKConfigModel)
    func setCertificates(_ certs: [String])
    func setPublicKey(_ key: String)
    func setAdditionalResourceUrls(_ url: [String])
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval)
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval)
    func setStoreCookies(_ storeCookies: Bool)
}

//MARK: - Real methods

class SDKInteractorReal: SDKInteractor {
    @ObservedObject var appState: AppState

    private static let staticBuilder = ClientBuilder()
    private var device: AppState.DeviceData { appState.deviceData }
    private var client: Client?
    var builder: ClientBuilder

    init(appState: AppState, client: Client? = nil, builder: ClientBuilder = SDKInteractorReal.staticBuilder) {
        self.appState = appState
        self.client = client
        self.builder = builder
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        guard !appState.system.isSDKInitialized else {
            appState.system.isProcessing = false
            appState.setSystemInfo(string: "SDK is already initialized.")
            return
        }

        builder.buildAndWaitForProtectedData { client in
            client.start { [self] error in
                if let error {
                    return result(.failure(error))
                } else {
                    appState.routing.backHome()
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
}

//MARK: - Private Protocol Extension
private extension SDKInteractorReal {
    
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        return ConfigModel(dictionary: model.dictionary)! // TODO: remove force unwrap?
    }
}
