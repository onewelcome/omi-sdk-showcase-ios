//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var appstate: AppState = {
        @Injected var appState: AppState
        return appState
    }()
    @ObservedObject var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()

    @State internal var category: Category
    @State internal var isExpanded = false
    @State internal var actions = [Action]()
    @State internal var errorValue = ""

    
    var body: some View {
        HStack {
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
                            Button(action: {
                                buttonAction(for: selection)
                            }, label: {
                                HStack {
                                    if let logo = selection.logo {
                                        Image(systemName: logo)
                                    }
                                    Text(selection.name)
                                }
                            }).disabled(selection.disabled)
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
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $system.shouldShowBrowser) {
            SheetViewForWebView(urlString: browserInteractor.registerUrl)
        }
        .sheet(isPresented: $system.shouldShowPinPad) {
            SheetViewForPinPad()
        }
        .sheet(isPresented: $system.shouldShowQRScanner) {
            SheetViewForQRScanner()
        }
        .onChange(of: appstate.registeredUsers) {
            updateUsersSelection()
        }
        .onChange(of: appstate.system.enrollmentState) {
            updateMobileAuthenticationCategorySelection()
        }
        .onChange(of: appstate.pendingTransactions) {
            pendingTransactionsTask()
        }
        .task {
            updateUsersSelection()
            updateMobileAuthenticationCategorySelection()
            pendingTransactionsTask()
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
    func pendingTransactionsTask() {
        guard category.type == .pendingTransactions else { return }
        Task {
            let pendingTransactions = await sdkInteractor.fetchMobileAuthPendingTransactionNames()
            category.selection = pendingTransactions.map { Selection(name: $0, type: .pending, logo: "doc.badge.clock") }
        }
    }
    
    func buttonAction(for option: Option) {
        switch option.type {
        case .initialize:
            system.isProcessing = true
            initializeSDK()
        case .reset:
            system.isProcessing = true
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
        let switcher = selection.type == .unknown ? selection.namedType : selection.type
        
        switch switcher {
        case .cancelRegistration:
            cancelRegistration()
        case .browserRegistration:
            browserRegistration()
        case .loginWithOtp:
            showQRScanner()
        case .pending:
            handlePending(transacationId: selection.name)
        case .authenticate:
            sdkInteractor.authenticateUser(optionName: selection.name)
        case .unknown:
            fatalError("Selection `\(selection.name)` not handled!")
        }
    }
}
