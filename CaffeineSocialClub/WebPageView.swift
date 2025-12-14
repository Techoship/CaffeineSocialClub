//
//  WebPageView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 14/12/2025.
//

import SwiftUI
import WebKit

struct WebPageView: View {
    @State private var isLoading = true
    @State private var showExitAlert = false
    @State private var canGoBack = false
    @State private var showNoInternetAlert = false
    
    var body: some View {
        ZStack {
            WebView(
                url: URL(string: "https://caffeinesocialclub.com/")!,
                isLoading: $isLoading,
                canGoBack: $canGoBack,
                showNoInternetAlert: $showNoInternetAlert
            )
            .edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .brown))
                        .scaleEffect(1.5)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                }
            }
        }
        .alert("No Internet Connection", isPresented: $showNoInternetAlert) {
            Button("Retry") {
                // Reload will be handled by WebView
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please check your internet connection and try again.")
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    @Binding var showNoInternetAlert: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        // Media playback
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsPictureInPictureMediaPlayback = true
        
        // Enable JavaScript features
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        // Data store for cookies and cache
        configuration.websiteDataStore = .default()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Navigation gestures
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        // Scrolling
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = true
        
        // Zoom
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 3.0
        
        // Performance
        webView.configuration.preferences.isFraudulentWebsiteWarningEnabled = true
        
        // Load the URL
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Updates handled by coordinator
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // MARK: - Navigation Delegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            
            // Inject CSS to improve mobile experience (optional)
            let css = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
            webView.evaluateJavaScript(css, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                   nsError.code == NSURLErrorNetworkConnectionLost {
                    parent.showNoInternetAlert = true
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain {
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                   nsError.code == NSURLErrorNetworkConnectionLost {
                    parent.showNoInternetAlert = true
                }
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Handle tel:, mailto:, etc.
            if let url = navigationAction.request.url {
                if url.scheme == "tel" || url.scheme == "mailto" || url.scheme == "sms" {
                    UIApplication.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        // MARK: - UI Delegate
        
        // Helper to get the active window scene
        private func getActiveViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                return nil
            }
            return rootViewController
        }
        
        // Handle JavaScript alerts
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler()
            }))
            
            if let viewController = getActiveViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler()
            }
        }
        
        // Handle JavaScript confirms
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            
            if let viewController = getActiveViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler(false)
            }
        }
        
        // Handle JavaScript prompts
        func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
            let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = defaultText
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(alert.textFields?.first?.text)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(nil)
            }))
            
            if let viewController = getActiveViewController() {
                viewController.present(alert, animated: true)
            } else {
                completionHandler(nil)
            }
        }
        
        // Handle new windows (target="_blank")
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Open in same webview instead of new window
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
        
        // Handle file uploads
        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            // File picker would go here - for now just cancel
            completionHandler(nil)
        }
    }
}

#Preview {
    WebPageView()
}
