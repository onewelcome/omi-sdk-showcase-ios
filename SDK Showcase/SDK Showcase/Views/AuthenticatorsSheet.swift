//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct AuthenticatorsSheet: View {
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    var sdkInteractor: SDKInteractor {
        @Injected var interactors: Interactors
        return interactors.sdkInteractor
    }
    var authRegistrationInteractor: AuthenticatorRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.authenticatorRegistrationInteractor
    }
    private var sheetTitle: String {
        if let _ = selectedOption?.name {
            return "Select the authenticator for authentication"
        } else if let authenticatedId = system.userState.userId, authRegistrationInteractor.unregisteredAuthenticatorNames(for: authenticatedId).count > 0 {
            return "Select the authenticator to register"
        } else {
            return "No authenticators left to register"
        }
    }
    
    var showConfirmationDialog: Binding<Bool>
    var selectedOption: Selection?
    var body: some View {
        Spacer()
            .confirmationDialog(sheetTitle, isPresented: showConfirmationDialog, titleVisibility: .visible) {
  
            if let profileId = selectedOption?.name  {
                ForEach(authRegistrationInteractor.authenticatorNames(for: profileId), id: \.self) { name in
                    Button(name) {
                        sdkInteractor.authenticateUser(profileName: profileId,
                                                       optionName: name)
                    }
                }
            } else if let authenticatedId = system.userState.userId {
                ForEach(authRegistrationInteractor.unregisteredAuthenticatorNames(for: authenticatedId), id: \.self) { name in
                    Button(name) {
                        authRegistrationInteractor.registerAuthenticator(name: name, for: authenticatedId)
                    }
                }
            }
        }
    }
}
