//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var system: AppState.System
    @State var category: Category
    @State private var isExpanded = false
    @State private var actions = [Action]()
    @State private var errorValue = ""
    @State private var isProcessing = false
    
    var body: some View {
        HStack {
            ZStack {
                List {
                    Text(category.description)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .onAppear {
                            if category.name == "User authentication" {
                                sdkInteractor.fetchUserProfiles()
                            }
                        }
                    
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
                                let disabled = selection.disabled && !system.hasError
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
                        TextResult(result: system.isSDKInitialized ? "✅ SDK initialized" : "❌ SDK not initialized \(errorValue)")
                        TextResult(result: userStatus)
                    }, header: {
                        Text("Result")
                    })
                }
                .listStyle(.insetGrouped)
                .shadow(radius: 5, x: 0, y: 5)
                
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
        .sheet(isPresented: $system.shouldShowBrowser) {
            SheetViewForWebView(urlString: browserInteractor.registerUrl)
        }
        .sheet(isPresented: $system.shouldShowPinPad) {
            SheetViewForPinPad()
        }
        HStack {
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
}

//MARK: - Actions
extension ContentView {
    func buttonAction(for option: Option) {
        switch option.name {
        case "Initialize":
            isProcessing = true
            initializeSDK()
        case "Reset":
            isProcessing = true
            resetSDK()
        case "Change PIN":
            changePIN()
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
        case let optionName where sdkInteractor.userAuthenticatorOptionNames.contains(optionName):
            sdkInteractor.authenticateUser(optionName: optionName)
        default:
            fatalError("Selection `\(selection.name)` not handled!")
        }
    }
}

private extension ContentView {
    func browserRegistration() {
        browserInteractor.register()
    }
    
    func cancelRegistration() {
        browserInteractor.cancelRegistration()
    }
}

//MARK: - Private
private extension ContentView {
    var userStatus: String {
        switch system.userState {
        case .authenticated(let userId):
            "👤 User authenticated as \(userId)"
        case .registered:
            "👥 At least one user is registered"
        default:
            "🚫 No registered"
        }
    }
    
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
        setBuilder()
        sdkInteractor.initializeSDK { result in
            switch result {
            case .success:
                system.unsetError()
                system.isSDKInitialized = true
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setError(errorValue)
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
                system.unsetError()
                system.isSDKInitialized = false
            case .failure(let error):
                errorValue = error.localizedDescription
                system.setError(errorValue)
                system.isSDKInitialized = false
            }
            isProcessing = false
        }
    }
    
    func changePIN() {
        sdkInteractor.changePin()
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
    
    var pinPadInteractor: PinPadInteractor {
        @Injected var interactors: Interactors
        return interactors.pinPadInteractor
    }
}
