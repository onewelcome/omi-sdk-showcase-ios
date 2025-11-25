//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import OneginiSDKiOS
import SwiftUI

protocol ResourceInteractor {
    func fetchDeviceList()
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
                app.setSystemInfo(string: error.localizedDescription)
            } else {
                if let data = response?.data,
                   let deviceList = try? self.decoder.decode(Devices.self, from: data) {
                    let showable = deviceList.devices.map { $0.name + " (\($0.id.truncated(10)))" }.joined(separator: "\n")
                    app.setSystemInfo(string: showable)
                }
            }
        }
    }
}
