//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI
import WebKit

class BrowserViewModel: NSObject, ObservableObject {
    var browserInteractor: BrowserRegistrationInteractor {
        @Injected var interactors: Interactors
        return interactors.browserInteractor
    }
    
    weak var webView: WKWebView? {
        didSet {
            webView?.navigationDelegate = self
        }
    }

    @Published var urlString = ""
    @Published var rediredURL: URL?
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isFinished = false
    @Published var errorMessage = ""
    
    init(url: URL) {
        self.urlString = url.absoluteString
    }

    func loadURLString() {
        if let url = URL(string: urlString) {
            webView?.load(URLRequest(url: url))
        }
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }
    
    func handleRedirectURL(_ url: URL) {
        rediredURL = url
        browserInteractor.didReceiveBrowserRegistrationRedirect(url)
    }
}

extension BrowserViewModel: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isFinished = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        isFinished = true
        guard rediredURL != nil else { return }
        
        errorMessage = error.localizedDescription
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isFinished = true
        guard rediredURL != nil else { return }
        
        errorMessage = error.localizedDescription
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        if url.absoluteString.hasPrefix("sdkshowcase://loginsuccess") {
            handleRedirectURL(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
