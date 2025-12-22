//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import WebKit
import LocalAuthentication

struct BrowserView: View {
    @StateObject var browserViewModel: BrowserViewModel
    @Binding var isLoading: Bool
    @Binding var errorString: String
    @Binding var redirectURL: URL?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                TextField("URL", text: $browserViewModel.urlString, onCommit: {
                    browserViewModel.loadURLString()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(true)
                
                Button(action: {
                    browserViewModel.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .tint(.black)
                }
            }
            .padding(.vertical)
            if let url = URL(string: browserViewModel.urlString) {
                BrowserWebView(viewModel: browserViewModel, url: url)
                    .onChange(of: browserViewModel.isFinished) { isLoading = false }
                    .onChange(of: browserViewModel.errorMessage) { errorString = $1 }
                    .onChange(of: browserViewModel.rediredURL) { redirectURL = $1; dismiss() }
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct BrowserWebView: UIViewRepresentable {
    @ObservedObject var viewModel: BrowserViewModel
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        viewModel.webView = webView
//        let contentController = WKUserContentController()
//        contentController.add(viewModel, name: "webauthn")
//        let config = WKWebViewConfiguration()
//        config.userContentController = contentController
//        config.preferences.isElementFullscreenEnabled = true
//        
//        config.websiteDataStore = .default() // crucial for webauth
//        config.defaultWebpagePreferences.allowsContentJavaScript = true
//        config.preferences.javaScriptCanOpenWindowsAutomatically = true
//        
//        let webView = WKWebView(frame: .zero, configuration: config)
//        viewModel.webView = webView
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        webView.load(request)
//        webView.loadHTMLString("""
//                <html>
//                <body>
//                <button onclick="test()">Testuj WebAuthn</button>
//                <script>
//                  async function test() {
//                        const message = {
//                          action: 'ping',
//                          data: 'Hello from JS!'
//                        };
//                          if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.webauthn) {
//                            window.webkit.messageHandlers.webauthn.postMessage(message);
//                            writeLog('📡 Wysłano message: ' + JSON.stringify(message));
//                          } else {
//                            writeLog('⚠️ Brak handlera: window.webkit.messageHandlers.webauthn');
//                          }
//                  }
//                </script>
//                </body>
//                </html>
//                """, baseURL: nil)

        // TODO: Force biometrics
//        let context = LAContext()
//        let reason = "log with biometrics"
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
//            DispatchQueue.main.async {
//                if success {
//                    print("✅ Uwierzytelniono pomyślnie!")
//                } else {
//                    print("❌ Błąd: \(error?.localizedDescription ?? "")")
//                }
//            }
//        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true    // opcjonalnie: tryb Reader
        return SFSafariViewController(url: url, configuration: config)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
