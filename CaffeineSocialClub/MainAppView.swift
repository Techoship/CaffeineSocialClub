//
//  MainAppView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @State private var selectedTab = 0
    @State private var showLogoutAlert = false
    @State private var navigateToLogin = false
    
    var body: some View {
        if navigateToLogin {
            SignupLoginView()
        } else {
            NavigationView {
                TabView(selection: $selectedTab) {
                    
                    
                    PostsView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    ProfileSettingsView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(1)
                    HomeView()
                        .tabItem {
                            Label("About US", systemImage: "document.fill")
                        }
                        .tag(2)
                }
                .navigationTitle("Caffeine Social Club")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                   
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
                .alert("Logout", isPresented: $showLogoutAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Logout", role: .destructive) {
                        performLogout()
                    }
                } message: {
                    Text("Are you sure you want to logout?")
                }
            }
        }
    }
    
    private func performLogout() {
        // Sign out from Firebase
        do {
            try Auth.auth().signOut()
            
            // Clear user data from UserDefaults
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "username")
            UserDefaults.standard.removeObject(forKey: "userId")
            
            // Navigate to login
            navigateToLogin = true
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainAppView()
}
