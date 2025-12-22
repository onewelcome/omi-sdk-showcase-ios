//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForPrompt: View {
    @Environment(\.dismiss) var dismiss
    @Injected private var registrationInteractor: RegistrationInteractor
    @State private var prompt: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            SheetViewDismiss()
            Form {
                Section(header: Text("Two step registration"),
                        footer: Text("In this example the prompt is: \"\(DummyData.customAuthInitialChallenge)\"")) {
                    Text("Provide the response for the request generated in the first step of the custom registration flow:")
                    SecureField(text: $prompt, prompt: Text("Prompt")) {
                        Text("Type the response here...")
                    }
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .onSubmit {
                        registrationInteractor.setUserPrompt(prompt)
                        dismiss()
                    }
                }
            }.task {
                try? await Task.sleep(for: .seconds(0.5))
                isFocused = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}

