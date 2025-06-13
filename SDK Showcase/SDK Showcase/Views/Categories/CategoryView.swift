//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct CategoryView: View {
    @ObservedObject var system: AppState.System
    @ObservedObject var userData: AppState.UserData
    @State var category: Category
    @State private var isExpanded = false
    @State private var actions = [Action]()
    @State private var errorValue = ""
    @State private var isProcessing = false
    @State private var isPresentingSheet = false
    
    var body: some View {
        HStack {
            ZStack {
                List {
                    Text(category.description)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    
                    if !category.requiredActions.isEmpty {
                        Section(header: Text("Required Actions")) {
                            ForEach(category.requiredActions, id:\.self) { action in
                                ActionView(action: binding(for: action))
                            }
                        }
                    }
                    
                    if !category.optionalActions.isEmpty {
                        Section(header: Text("Optional Actions")) {
                            ForEach(category.optionalActions, id:\.self) { action in
                                ActionView(action: binding(for: action))
                            }
                        }
                    }
                    
                    if !category.selection.isEmpty {
                        Section(header: Text("Select")) {
                            ForEach(category.selection, id:\.self) { selection in
                                let disabled = selection.disabled && !system.isError
                                Button(action: {
                                    buttonAction(for: selection)
                                }, label: {
                                    HStack {
                                        if let logo = selection.logo {
                                            Image(systemName: logo)
                                        }
                                        Text(selection.name)
                                    }
                                }).disabled(disabled)
                            }
                        }
                    }
                    
                    Section(content: {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            TextResult(result: system.isSDKInitialized ? "SDK initialized" : "SDK not initialized \(errorValue)")
                            TextResult(result: system.isRegistered ? "User registered as \(userData.userId ?? "")" : "User not registered")
                        }
                    }, header: {
                        Text("Result")
                    })
                }
                .listStyle(.insetGrouped)
                
                if isProcessing {
                    Spinner()
                }
                
                if let info = system.lastErrorDescription {
                    Alert(text: info)
                }
            } // ZStack
        } // HStack
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPresentingSheet) {
            SheetViewForWebView(urlString: browserInteractor.registerUrl)
        }
        
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
            fatalError("Option `\(option.name)` not handled!")
        }
    }
    
    func buttonAction(for selection: Selection) {
        switch selection.name {
        case "Cancel registration":
            cancelRegistration()
        case "Browser registration":
            browserRegistration()
        default:
            fatalError("Selection `\(selection.name)` not handled!")
        }
    }
}

private extension CategoryView {
    func browserRegistration() {
        browserInteractor.register {
            isProcessing = false
            isPresentingSheet = true
        }
    }
    
    func cancelRegistration() {
        browserInteractor.cancelRegistration()
    }
}

//MARK: - Private
private extension CategoryView {
    func setBuilder() {
        sdkInteractor.setConfigModel(SDKConfigModel.default)
        sdkInteractor.setPublicKey(value(for: "setPublicKey"))
        sdkInteractor.setCertificates([value(for: "setX509PEMCertificates")])
        sdkInteractor.setAdditionalResourceUrls(value(for: "setAdditionalResourceURL"))
        sdkInteractor.setStoreCookies(value(for: "setStoreCookies"))
        sdkInteractor.setHttpRequestTimeout(value(for: "setHttpRequestTimeout"))
        sdkInteractor.setDeviceConfigCacheDuration(value(for: "setDeviceConfigCacheDuration"))
    }
    
    func initializeSDK() {
        errorValue.removeAll()
        /// You can comment the below line if the app is configured with the configurator and do have OneginiConfigModel set.
        //setBuilder()
        sdkInteractor.initializeSDK { result in
            switch result {
            case .success:
                system.isError = false
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
        sdkInteractor.resetSDK { result in
            switch result {
            case .success:
                system.isError = false
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
            return [] as? T
            ?? String() as? T
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
    
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    
    var browserInteractor: BrowserRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.browserInteractor
    }
}
