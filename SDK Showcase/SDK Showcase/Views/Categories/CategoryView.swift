//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct CategoryView: View {
    @ObservedObject var system: AppState.System
    @State var category: Category
    @State private var isExpanded = false
    @State private var actionValue = [String: Any]()
    @State private var errorValue = ""
    @State private var isProcessing = false
    
    var body: some View {
        HStack {
            List {
                Text(category.description)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                
                Section(header: Text("Required Actions")) {
                    ForEach(category.requiredActions, id:\.self) { action in
                        ActionView(action: binding(for: action))
                    }
                }
                
                Section(header: Text("Optional Actions")) {
                    ForEach(category.optionalActions, id:\.self) { action in
                        ActionView(action: binding(for: action))
                    }
                }
                
                Section(content: {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        TextResult(result: system.isSDKInitialized ? "SDK initialized" : "SDK not initialized \(errorValue)")
                    }
                }, header: {
                    Text("Result")
                })
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        
        ForEach(category.options) { option in
            Button(action: {
                buttonAction(for: option)
            }, label: {
                HStack {
                    if let logo = option.logo {
                        Image(systemName: logo)
                    }
                    Text(option.name)
                }
            })
            .padding()
        }
    }
}

//MARK: - Actions
extension CategoryView {
    func buttonAction(for option: Option) {
        isProcessing = true
        switch option.name {
        case "Initialize":
            initializeSDK()
        case "Reset":
            resetSDK()
        default:
            break
        }
    }
}

//MARK: - Private
private extension CategoryView {
    func setBuilder() {
        errorValue.removeAll()
        interactor.setConfigModel(SDKConfigModel.default)
        
        if let key = actionValue["setPublicKey"] as? String {
            interactor.setPublicKey(key)
        }
        if let cert = actionValue["setX509PEMCertificates"] as? String {
            interactor.setCertificates([cert])
        }
        if let resourceURL = actionValue["setAdditionalResourceURL"] as? String {
            interactor.setAdditionalResourceURL(resourceURL)
        }
        if let cookies = actionValue["setStoreCookies"] as? String, let bcookies = Bool(cookies) {
            interactor.setStoreCookies(bcookies)
        }
        if let timeout = actionValue["setHttpRequestTimeout"] as? String, let ttimeout = TimeInterval(timeout) {
            interactor.setHttpRequestTimeout(ttimeout)
        }
        if let duration = actionValue["setDeviceConfigCacheDuration"] as? String, let tduration = TimeInterval(duration) {
            interactor.setDeviceConfigCacheDuration(tduration)
        }
    }
    
    func initializeSDK() {
        setBuilder()
        interactor.initializeSDK { result in
            switch result {
            case .success:
                system.isSDKInitialized = true
            case .failure(let error):
                errorValue = error.localizedDescription
                system.isSDKInitialized = false
            }
            isProcessing = false
        }
    }
    
    func resetSDK() {
        setBuilder()
        interactor.resetSDK { result in
            switch result {
            case .success:
                system.isSDKInitialized = false
            case .failure(let error):
                errorValue = error.localizedDescription
                system.isSDKInitialized = false
            }
            isProcessing = false
        }
    }
    
    func binding(for action: Action) -> Binding<Action> {
        DispatchQueue.main.async {
            actionValue[action.name] = action.defaultValue
        }
        
        return .init(
            get: {
                return action
            },
            set: {
                switch action.type {
                case .boolean:
                    actionValue[action.name] = $0.boolValue
                case .string:
                    actionValue[action.name] = $0.value;
                }
            }
        )
    }
    
    var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
}
