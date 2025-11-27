//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS
import SwiftUI

protocol ResourceInteractor {
    func fetchDeviceList()
    func fetchImplicit()
}

class ResourceInteractorReal: ResourceInteractor {
    private let userClient = SharedUserClient.instance
    private let decoder = JSONDecoder()
    @ObservedObject var app: ShowcaseApp

    init(app: ShowcaseApp) {
        self.app = app
    }
    
    func fetchDeviceList() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "devices", method: .get)
        userClient.sendAuthenticatedRequest(request) { [self] response, error in
            if let error = error {
                handleError(error)
            } else {
                if let data = response?.data,
                   let deviceList = try? self.decoder.decode(Devices.self, from: data) {
                   let showable = deviceList.devices.map { $0.name + " (\($0.id.truncated(10)))" }.joined(separator: "\n")
                    handleData(showable)
                }
            }
        }
    }
    
    func fetchImplicit() {
        let request = ResourceRequestFactory.makeResourceRequest(path: "user-id-decorated", method: .get)
        userClient.sendImplicitRequest(request) { [self] response, error in
            if let error = error {
                handleError(error)
            } else {
                if let data = response?.data,
                   let responseData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let userIdDecorated = responseData["decorated_user_id"] {
                    handleData(userIdDecorated)
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
