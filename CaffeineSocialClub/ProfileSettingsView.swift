//
//  ProfileSettingsView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showReauthAlert = false
    @State private var deletePassword = ""
    @State private var isDeleting = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var navigateToLogin = false
    
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false
    
    private let database = Database.database().reference()
    
    var currentUser: (userId: String, username: String, email: String)? {
        guard let userId = UserPreferencesManager.shared.userId,
              let username = UserPreferencesManager.shared.username,
              let email = UserPreferencesManager.shared.userEmail else {
            return nil
        }
        return (userId, username, email)
    }
    
    var body: some View {
        if navigateToLogin {
            SignupLoginView()
        } else {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.brown.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(getUserInitial())
                                        .font(.system(size: 40))
                                        .fontWeight(.bold)
                                        .foregroundColor(.brown)
                                )
                            
                            if let user = currentUser {
                                Text(user.username)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Account Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Account")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                // Email
                                SettingRow(
                                    icon: "envelope.fill",
                                    title: "Email",
                                    value: currentUser?.email ?? "Not available",
                                    color: .blue
                                )
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // User ID
                                SettingRow(
                                    icon: "person.fill",
                                    title: "User ID",
                                    value: String(currentUser?.userId.prefix(8) ?? "") + "...",
                                    color: .green
                                )
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Privacy & Data Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Privacy & Data")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                // Download Data
                                Button(action: downloadUserData) {
                                    SettingRow(
                                        icon: "arrow.down.doc.fill",
                                        title: "Download My Data",
                                        value: "",
                                        color: .purple,
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // Privacy Policy
                                Button(action: openPrivacyPolicy) {
                                    SettingRow(
                                        icon: "hand.raised.fill",
                                        title: "Privacy Policy",
                                        value: "",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                // Terms of Service
                                Button(action: openTermsOfService) {
                                    SettingRow(
                                        icon: "doc.text.fill",
                                        title: "Terms of Service",
                                        value: "",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Danger Zone
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Danger Zone")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                Button(action: { showDeleteAlert = true }) {
                                    VStack(alignment: .leading, spacing: 4){
                                        HStack(spacing: 16) {
                                            Image(systemName: "trash.fill")
                                                .font(.title3)
                                                .foregroundColor(.white)
                                                .frame(width: 40, height: 40)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                            Text("Delete Account")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        Text("Permanently delete your account and all data")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    .padding()
                                }
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // Error Message
                        if showError {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .alert("Delete Account", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        showReauthAlert = true
                    }
                } message: {
                    Text("This action cannot be undone. All your posts, comments, and data will be permanently deleted.")
                }
                .alert("Confirm Password", isPresented: $showReauthAlert) {
                    SecureField("Password", text: $deletePassword)
                    Button("Cancel", role: .cancel) {
                        deletePassword = ""
                    }
                    Button("Delete Forever", role: .destructive) {
                        deleteAccount()
                    }
                } message: {
                    Text("Please enter your password to confirm account deletion.")
                }
            }.sheet(isPresented: $showShareSheet) {
                Group {
                    if let url = exportedFileURL {
                        ShareSheet(items: [url])
                            .presentationDetents([.medium, .large])
                        
                    }
                }
            }


        }
    }
    
    // MARK: - Helper Methods
    
    private func getUserInitial() -> String {
        if let username = currentUser?.username {
            return String(username.prefix(1).uppercased())
        }
        return "U"
    }
    
    private func downloadUserData() {
        guard let userId = currentUser?.userId else { return }

        database.child("users").child(userId).getData { error, snapshot in

            guard error == nil, let userData = snapshot?.value else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to fetch user data"
                    self.showError = true
                }
                return
            }

            database.child("posts")
                .queryOrdered(byChild: "userId")
                .queryEqual(toValue: userId)
                .observeSingleEvent(of: .value) { postsSnapshot in

                    let exportData: [String: Any] = [
                        "user": userData,
                        "posts": postsSnapshot.value ?? [:],
                        "exportDate": Date().ISO8601Format()
                    ]

                    do {
                        let jsonData = try JSONSerialization.data(
                            withJSONObject: exportData,
                            options: .prettyPrinted
                        )

                        let fileName = "caffeine_data_\(userId).json"
                        let url = FileManager.default
                            .temporaryDirectory
                            .appendingPathComponent(fileName)

                        try jsonData.write(to: url)

                        DispatchQueue.main.async {
                            self.exportedFileURL = url
                            self.showShareSheet = true
                        }


                    } catch {
                        DispatchQueue.main.async {
                            self.errorMessage = "Failed to export data"
                            self.showError = true
                        }
                    }
                }
        }
    }

    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://caffeinesocialclub.com/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://caffeinesocialclub.com/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser,
              let userId = currentUser?.userId,
              let email = currentUser?.email,
              !deletePassword.isEmpty else {
            errorMessage = "Please enter your password"
            showError = true
            deletePassword = ""
            return
        }
        
        isDeleting = true
        
        // Re-authenticate user before deletion (required by Firebase)
        let credential = EmailAuthProvider.credential(withEmail: email, password: deletePassword)
        
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Invalid password: \(error.localizedDescription)"
                showError = true
                isDeleting = false
                deletePassword = ""
                return
            }
            
            // Delete user data from database
            deleteUserData(userId: userId) {
                // Delete Firebase Auth account
                user.delete { error in
                    isDeleting = false
                    deletePassword = ""
                    
                    if let error = error {
                        errorMessage = "Failed to delete account: \(error.localizedDescription)"
                        showError = true
                    } else {
                        // Clear local data
                        UserPreferencesManager.shared.clearUserData()
                        
                        // Navigate to login
                        navigateToLogin = true
                    }
                }
            }
        }
    }
    
    private func deleteUserData(userId: String, completion: @escaping () -> Void) {
        // Delete user profile
        database.child("users").child(userId).removeValue()
        
        // Delete user's posts
        database.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let snap = child as? DataSnapshot {
                    self.database.child("posts").child(snap.key).removeValue()
                    
                    // Delete comments on user's posts
                    self.database.child("comments").child(snap.key).removeValue()
                }
            }
            
            // Delete user's comments on other posts
            self.database.child("comments").observeSingleEvent(of: .value) { snapshot in
                for postChild in snapshot.children {
                    if let postSnap = postChild as? DataSnapshot {
                        for commentChild in postSnap.children {
                            if let commentSnap = commentChild as? DataSnapshot,
                               let commentData = commentSnap.value as? [String: Any],
                               let commentUserId = commentData["userId"] as? String,
                               commentUserId == userId {
                                self.database.child("comments").child(postSnap.key).child(commentSnap.key).removeValue()
                            }
                        }
                    }
                }
                
                completion()
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var showChevron: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                if !value.isEmpty {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

#Preview {
    ProfileSettingsView()
}
