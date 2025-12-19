//
//  SplashView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 14/12/2025.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseRemoteConfig

struct SplashView: View {
    @State private var isLoading = true
    @State private var showWebView = false
    @State private var navigateToApp = false
    @State private var navigateToLogin = false
    @State private var showTermsAcceptance = false
    @State private var hasAcceptedTerms = false
    
    private let database = Database.database().reference()
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    var body: some View {
        ZStack {
            if isLoading {
                // Splash Screen
                VStack(spacing: 20) {
                    Image("ic_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80,height: 80)
                    
                    Text("Caffeine Social Club")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .brown))
                        .scaleEffect(1.5)
                }
            } else if showTermsAcceptance {
                TermsAcceptanceView(hasAcceptedTerms: $hasAcceptedTerms)
            } else if showWebView {
                WebPageView()
            } else if navigateToApp {
                MainAppView()
            } else if navigateToLogin {
                SignupLoginView()
            }
        }.onChange(of: hasAcceptedTerms, initial: hasAcceptedTerms, { oldValue, newValue in
            if newValue {
                // User accepted terms, proceed to auth check
                showTermsAcceptance = false
                checkAuthState()
            }
            
        })
        .onAppear {
            configureRemoteConfig()
            checkSettings()
        }
    }
    
    private func configureRemoteConfig() {
        let settings = RemoteConfigSettings()
        // For development: short cache expiration
        // For production: use longer cache (3600 seconds = 1 hour)
        settings.minimumFetchInterval = 0 // Use 3600 for production
        remoteConfig.configSettings = settings
        
        // Set default values
        let defaults: [String: NSObject] = [
            "ios_caffine_web_view_visible": false as NSObject
        ]
        remoteConfig.setDefaults(defaults)
    }
    
    private func checkSettings() {
        // Fetch and activate Remote Config values
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Remote Config fetch error: \(error.localizedDescription)")
                // Use default value on error
                handleRemoteConfigValue(useDefault: true)
                return
            }
            
            // Successfully fetched, use the value
            handleRemoteConfigValue(useDefault: false)
        }
    }
    
    private func handleRemoteConfigValue(useDefault: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Get the Remote Config value
            let showWebViewValue = remoteConfig.configValue(forKey: "ios_caffine_web_view_visible").boolValue
            
            if showWebViewValue {
                showWebView = true
                navigateToApp = false
                navigateToLogin = false
            } else {
                // Check if user has accepted terms
                let hasAccepted = UserDefaults.standard.bool(forKey: "hasAcceptedTerms")
                
                if !hasAccepted {
                    // Show terms acceptance first
                    showTermsAcceptance = true
                } else {
                    // Terms already accepted, proceed to auth check
                    checkAuthState()
                }
            }
            isLoading = false
        }
    }
    
    private func checkAuthState() {
        // Check Firebase Auth and UserDefaults
        let currentUser = Auth.auth().currentUser
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if currentUser != nil && isLoggedIn {
            // User is logged in
            navigateToApp = true
            navigateToLogin = false
        } else {
            // User is not logged in, clear any stale data
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "userId")
            
            navigateToLogin = true
            navigateToApp = false
        }
    }
}

#Preview {
    SplashView()
}
