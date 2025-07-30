//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var appstate: AppState
    @ObservedObject var system: AppState.System
    @State internal var category: Category
    @State internal var isExpanded = false
    @State internal var actions = [Action]()
    @State internal var errorValue = ""
    @State internal var isProcessing = false
    
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
                        TextResult(result: initializationStatus)
                        TextResult(result: userStateDescription)
                        if case .authenticated = system.userState {
                            TextResult(result: enrollmentStateDescription)
                        }
                    }, header: {
                        Text("Result")
                    })
                }
                .listStyle(.insetGrouped)
                .shadow(radius: 5, x: 0, y: 5)
                
                if isProcessing {
                    Spinner()
                }
                
                if let info = system.lastInfoDescription {
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
        .onChange(of: appstate.registeredUsers) {
            guard category.type == .userAuthentication else { return }
            
            category.selection = sdkInteractor.userAuthenticatorOptionNames.map { Selection(name: $0) }
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
        switch option.type {
        case .initialize:
            isProcessing = true
            initializeSDK()
        case .reset:
            isProcessing = true
            resetSDK()
        case .changePin:
            changePIN()
        case .enroll:
            enrollForMobileAuthentication()
        case .pushes:
            registerForPushes()
        default:
            fatalError("Option `\(option.name)` not handled!")
        }
    }
    
    func buttonAction(for selection: Selection) {
        switch selection.type {
        case .cancelRegistration:
            cancelRegistration()
        case .browserRegistration:
            browserRegistration()
        case .unknown:
            if sdkInteractor.userAuthenticatorOptionNames.contains(selection.name) {
                sdkInteractor.authenticateUser(optionName: selection.name)
            } else {
                fatalError("Selection `\(selection.name)` not handled!")
            }
        }
    }
}
