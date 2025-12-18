//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct LoadingWebView: View {
    @State private var isLoading = false // TODO: temporaray
    @State private var errorMessage = ""
    @State private var error: Error? = nil
    @State private var redirectURL: URL? = nil
    
    let url: URL?
    
    var body: some View {
        if let error = error {
            Text(error.localizedDescription)
                .foregroundColor(.pink)
        } else if let url {
            ZStack {
                BrowserView(browserViewModel: BrowserViewModel(url: url),
                            isLoading: $isLoading,
                            errorString: $errorMessage,
                            redirectURL: $redirectURL)
                .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    Spinner()
                }
                
                if !errorMessage.isEmpty && redirectURL == nil {
                    Text(errorMessage)
                        .padding()
                        .bold()
                        .tint(.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .foregroundColor(.red)
                }
            }
        } else {
            Text("Sorry, we could not load this url.")
        }
    }
}
