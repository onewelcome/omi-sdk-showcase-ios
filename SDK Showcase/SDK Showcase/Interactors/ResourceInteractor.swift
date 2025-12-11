//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS
import SwiftUI

protocol ResourceInteractor {
    /// Requests performed on UserClient
    func sendAuthenticatedRequest()
    func sendImplicitRequest()
    
    /// Requests performed on UserDevice
    func sendUnauthenticatedRequest()
    func sendAnonymousRequest()
}

class ResourceInteractorReal: ResourceInteractor {
    private let userClient = SharedUserClient.instance
    private let deviceClient = SharedDeviceClient.instance
    private let decoder = JSONDecoder()
    @ObservedObject var app: ShowcaseApp

    init(app: ShowcaseApp) {
        self.app = app
    }
    
    func sendUnauthenticatedRequest() {
        // Should be defined on the access
        let pathToTheResource = "path-to-the-resource"
        let request = ResourceRequestFactory.makeResourceRequest(path: pathToTheResource)
        deviceClient.sendUnauthenticatedRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                self?.handleData("unauthenticated request for the resource has been fetched.")
            }
        }
    }
    
    func sendAnonymousRequest() {
        let pathToTheResource = "application-details"
        let request = ResourceRequestFactory.makeResourceRequest(path: pathToTheResource)
        deviceClient.sendRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                self?.handleData("anonymous request for the resource has been fetched.")
            }
        }
    }
    
    func sendAuthenticatedRequest() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "devices", method: .get)
        userClient.sendAuthenticatedRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                if let data = response?.data,
                   let deviceList = try? self?.decoder.decode(Devices.self, from: data) {
                   let showable = deviceList.devices.map { $0.name + " (\($0.id.truncated(10)))" }.joined(separator: "\n")
                    self?.handleData(showable)
                }
            }
        }
    }
    
    func sendImplicitRequest() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "user-id-decorated", method: .get)
        userClient.sendImplicitRequest(request) { [weak self] response, error in
            if let error {
                self?.handleError(error)
            } else {
                if let data = response?.data,
                   let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let userIdDecorated = responseData["decorated_user_id"] {
                    self?.handleData(userIdDecorated)
                }
            }
        }
    }
}

private extension ResourceInteractorReal {
    func handleError(_ error: Error) {
        DispatchQueue.main.async { [app] in
            app.setSystemInfo(string: error.localizedDescription)
        }
    }
    
    func handleData(_ dataString: String) {
        DispatchQueue.main.async { [app] in
            app.setSystemInfo(string: dataString)
        }
    }
}
