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
    @State private var showFollowRequests = false
    
    var body: some View {
        if navigateToLogin {
            SignupLoginView()
        } else {
            NavigationView {
                TabView(selection: $selectedTab) {
                    
                    // Home/Feed Tab
                    PostsView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    // Cafeterias Tab (NEW)
                    CafeteriaListingsView()
                        .tabItem {
                            Label("Cafes", systemImage: "cup.and.saucer.fill")
                        }
                        .tag(1)
                    
                    // Profile Tab
                    ProfileSettingsView()
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                        .tag(2)
                    
                    // About Us Tab
                    HomeView()
                        .tabItem {
                            Label("About", systemImage: "info.circle.fill")
                        }
                        .tag(3)
                }
                .navigationTitle(getNavigationTitle())
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Follow requests button (left side)
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button(action: {
//                            showFollowRequests = true
//                        }) {
//                            ZStack(alignment: .topTrailing) {
//                                Image(systemName: "person.2.fill")
//                                    .foregroundColor(.brown)
//                                
//                                // Badge for pending requests
//                                Circle()
//                                    .fill(Color.red)
//                                    .frame(width: 8, height: 8)
//                                    .offset(x: 8, y: -8)
//                            }
//                        }
//                    }
                    
                    // Logout button (right side)
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
                .sheet(isPresented: $showFollowRequests) {
                    FollowRequestsView()
                }
            }
        }
    }
    
    private func getNavigationTitle() -> String {
        switch selectedTab {
        case 0:
            return "Caffeine Social Club"
        case 1:
            return "Cafeterias"
        case 2:
            return "My Profile"
        case 3:
            return "About Us"
        default:
            return "Caffeine Social Club"
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
