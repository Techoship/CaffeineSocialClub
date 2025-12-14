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
    @State private var showSettings = false
    @State private var navigateToLogin = false
    
    var body: some View {
        if navigateToLogin {
            SignupLoginView()
        } else {
            NavigationView {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    PostsView()
                        .tabItem {
                            Label("Posts", systemImage: "text.bubble.fill")
                        }
                        .tag(1)
                }
                .navigationTitle(selectedTab == 0 ? "Home" : "Posts")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    
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
                .sheet(isPresented: $showSettings) {
                    ProfileSettingsView()
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
