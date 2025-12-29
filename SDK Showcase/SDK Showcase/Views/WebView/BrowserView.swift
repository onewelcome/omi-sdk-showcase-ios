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
//        let webView = WKWebView()
//        viewModel.webView = webView
        let contentController = WKUserContentController()
        contentController.add(viewModel, name: "webauthn-viewModel")
        contentController.add(WebAuthnMessageHandler(), name: "webauthn")
        
        // inject script
        let injectedJS = """
                (function () {
                  console.log("HOOK INSTALLED");
                  if (!navigator.credentials?.create) return;

                  const originalCreate = navigator.credentials.create.bind(navigator.credentials);

                  navigator.credentials.create = async function (options) {
                    console.group("🟢 WebAuthn create() intercepted");

                    // INPUT (payload wejściowy)
                    console.log("INPUT options:", options);

                    const credential = await originalCreate(options);

                    // OUTPUT (payload wyjściowy)
                    const clientDataJSON = JSON.parse(
                      new TextDecoder().decode(credential.response.clientDataJSON)
                    );

                    console.log("OUTPUT id:", credential.id);
                    console.log("OUTPUT clientDataJSON:", clientDataJSON);
                    console.log(
                      "OUTPUT attestationObject (base64url):",
                      bufferToBase64Url(credential.response.attestationObject)
                    );

                    console.groupEnd();

                    return credential;
                  };

                  function bufferToBase64Url(buffer) {
                    const bytes = new Uint8Array(buffer);
                    let str = "";
                    for (const b of bytes) str += String.fromCharCode(b);
                    return btoa(str)
                      .replace(/\\+/g, "-")
                      .replace(/\\//g, "_")
                      .replace(/=+$/, "");
                  }
                })();
                """

                let userScript = WKUserScript(
                    source: injectedJS,
                    injectionTime: .atDocumentStart,
                    forMainFrameOnly: false
                )

                contentController.addUserScript(userScript)
        
        
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences.isElementFullscreenEnabled = true
        
        config.websiteDataStore = .default() // crucial for webauth
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        viewModel.webView = webView
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

//        webView.evaluateJavaScript("""
//        setTimeout(() => {
//          navigator.credentials.create({
//            publicKey: {
//              challenge: new Uint8Array([9,9,9]),
//              rp: { name: "Hook Test", id: location.hostname },
//              user: {
//                id: new Uint8Array([9]),
//                name: "hook-test",
//                displayName: "Hook Test"
//              },
//              pubKeyCredParams: [{ alg: -7, type: "public-key" }]
//            }
//          }).catch(() => {});
//        }, 1000);
//        """)
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


final class WebAuthnMessageHandler: NSObject, WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        print(">> WebAuthnMessageHandler message body: \(message.body)")
        guard message.name == "webauthn",
              let body = message.body as? [String: Any],
              let type = body["type"] as? String,
              let options = body["options"] else {
            return
        }

        print("🟢 WebAuthn \(type.uppercased())")
        print(options)
    }
}
