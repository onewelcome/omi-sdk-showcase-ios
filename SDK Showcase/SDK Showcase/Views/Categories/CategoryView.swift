//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI
 
struct CategoryView: View {
    @ObservedObject var system: AppState.System
    @State var category: Category
    private var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var body: some View {
        Text(category.description)
        if let option = category.optionalActions.first {
            Button(action: {
                interactor.initializeSDK { e in
                    system.isSDKInitialized = e == nil
                }
            }, label: {
                Text(option.name)
            }).disabled(system.isSDKInitialized)
        }
        Toggle(isOn: $system.isSDKInitialized) {
            Text("isInitialized")
        }.disabled(true)

    }
}

