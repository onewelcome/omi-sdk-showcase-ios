//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct PendingTransactionConfirmationSheet: View {
    var showConfirmationDialog: Binding<Bool>
    var selectedOption: Selection?
    var body: some View {
        Spacer()
        .confirmationDialog(sheetTitle, isPresented: showConfirmationDialog, titleVisibility: .visible) {
            let transacationId = selectedOption!.name
            Button("confirm") {
                mobileAuthRequestInteractor.handlePendingTransaction(id: transacationId, confirmed: true)
            }
            Button("decline") {
                mobileAuthRequestInteractor.handlePendingTransaction(id: transacationId, confirmed: false)
            }
            Button("cancel") {
                // cancel the sheet
            }
        }
    }
}

private extension PendingTransactionConfirmationSheet {
    var mobileAuthRequestInteractor: MobileAuthRequestInteractor {
        @Injected var interactors: Interactors
        return interactors.mobileAuthRequestInteractor
    }
    var sheetTitle: String {
        "Transaction: \(selectedOption?.name ?? "unknown")"
    }
}
