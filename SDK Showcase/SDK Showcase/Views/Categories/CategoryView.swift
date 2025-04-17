//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct CategoryView: View {
    @ObservedObject var system: AppState.System
    @State var category: Category
    @State private var isExpanded = false
    @State private var actions = [Action]()
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
        interactor.setConfigModel(SDKConfigModel.default)
        interactor.setPublicKey(value(for: "setPublicKey"))
        interactor.setCertificates([value(for: "setX509PEMCertificates")])
        interactor.setAdditionalResourceURL(value(for: "setAdditionalResourceURL"))
        interactor.setStoreCookies(value(for: "setStoreCookies"))
        interactor.setHttpRequestTimeout(value(for: "setHttpRequestTimeout"))
        interactor.setDeviceConfigCacheDuration(value(for: "setDeviceConfigCacheDuration"))
    }
    
    func initializeSDK() {
        errorValue.removeAll()
        /// You can comment the below line if the app is configured with the configurator and do have OneginiConfigModel set.
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
        errorValue.removeAll()
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
        setDefaultValueIfNeeded(for: action)
        return .init(
            get: {
                return actions.first { $0 == action } ?? action
            },
            set: { newAction in
                actions.removeAll { $0 == action }
                actions.append(newAction)
            }
        )
    }
    
    func setDefaultValueIfNeeded(for action: Action) {
        DispatchQueue.main.async {
            if !actions.contains(action) {
                actions.append(action)
            }
        }
    }
    
    func value<T>(for key: String) -> T {
        guard let action = actions.first(where: { $0.name == key }),
            let value = action.providedValue ?? action.defaultValue else {
            return String() as? T
            ?? Int() as? T
            ?? Double() as? T
            ?? Bool() as! T
        }
        
        guard let cast = value as? T else {
            switch T.self {
            case is Int.Type:
                return Int(value as! String) as! T
            case is Double.Type:
                return Double(value as! String) as! T
            default:
                fatalError("Unsupported type \(type(of: value))")
            }
        }

        print("[v] Setting value `\(value)` for key `\(key)`")
        return cast
    }
    
    var interactor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
}
