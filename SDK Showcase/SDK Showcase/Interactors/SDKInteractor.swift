//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import OneginiSDKiOS

//MARK: - Protocol
protocol SDKInteractor {
    func initializeSDK(result: @escaping SDKResult)
    func resetSDK(result: @escaping SDKResult)
    
    func setConfigModel(_ model: SDKConfigModel)
    func setCertificates(_ certs: [String])
    func setPublicKey(_ key: String)
    func setAdditionalResourceURL(_ url: String)
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval)
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval)
    func setStoreCookies(_ storeCookies: Bool)
}

//MARK: - Real methods
struct SDKInteractorReal: SDKInteractor {
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval) {
        
    }
    
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval) {
        
    }
    
    func setStoreCookies(_ storeCookies: Bool) {
        
    }
    
    func setAdditionalResourceURL(_ url: String) {
        
    }
    
    func setPublicKey(_ key: String) {
        
    }
    
    func setCertificates(_ certs: [String]) {
        
    }
    
    
    func setConfigModel(_ model: SDKConfigModel) {
        
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        withoutActuallyEscaping(result) { r in
            SharedClient.instance.start { error in
                if let error {                    
                    return r(.failure(error))
                } else {
                    return r(.success)
                }
            }
        }
    }
    
    func resetSDK(result: @escaping SDKResult) {
        
    }
}

//MARK: - Stubbed methods
struct SDKInteractorStub: SDKInteractor {

    @ObservedObject var appState: AppState
    private var device: AppState.DeviceData {
        return appState.deviceData
    }
    
    private static let builder = ClientBuilder()

    func setConfigModel(_ model: SDKConfigModel) {
        let mappedModel = mapSDKConfigModel(model)
        device.configModel = mappedModel // tu?
        _ = Self.builder.setConfigModel(mappedModel)
    }
    func setCertificates(_ certs: [String]) {
        device.certs = certs // tu?
        _ = Self.builder.setX509PEMCertificates(certs) // a moze builder w DeviceData?
    }
    
    func setAdditionalResourceURL(_ url: String) {
        _ = Self.builder.setAdditionalResourceUrls([url])
    }
    
    func setDeviceConfigCacheDuration(_ cacheDuration: TimeInterval) {
        _ = Self.builder.setDeviceConfigCacheDuration(cacheDuration)
    }
    
    func setHttpRequestTimeout(_ requestTimeout: TimeInterval) {
        _ = Self.builder.setHttpRequestTimeout(requestTimeout)
    }
    
    func setStoreCookies(_ storeCookies: Bool) {
        _ = Self.builder.setStoreCookies(storeCookies)
    }
    
    
    func setPublicKey(_ key: String) {
        device.publicKey = key
        Self.builder.setServerPublicKey(key)
    }
    
    func initializeSDK(result: @escaping SDKResult) {
        Self.builder.buildAndWaitForProtectedData { client in
            client.start { error in
                if let error {
                    return result(.failure(error))
                } else {
                    return result(.success)
                }
            }
        }
    }
    
    func resetSDK(result: @escaping SDKResult) {
        Self.builder.buildAndWaitForProtectedData { client in
            client.reset { error in
                if let error {
                    return result(.failure(error))
                } else {
                    return result(.success)
                }
            }
        }
    }

}

//MARK: - Private
private extension SDKInteractor {
    func mapSDKConfigModel(_ model: SDKConfigModel) -> OneginiSDKiOS.ConfigModel {
        return ConfigModel(dictionary: model.dictionary)
    }
}
