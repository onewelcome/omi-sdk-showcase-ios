//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewDismiss: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    @Injected private var pinPadInteractor: PinPadInteractor
    @Injected private var browserInteractor: BrowserRegistrationInteractor

    var body: some View {
        HStack {
            Button {
                dismiss()
                pinPadInteractor.cancelCreatingPIN()
                pinPadInteractor.cancelChangingPIN()
                browserInteractor.cancelRegistration()
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}
