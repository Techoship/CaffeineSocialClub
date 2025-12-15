//
//  SignupLoginView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabaseInternal

struct SignupLoginView: View {
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.brown.opacity(0.3), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Logo and Title
                        VStack(spacing: 16) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.brown)
                                .padding(.top, 40)
                            
                            Text("Caffeine Social Club")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(isLogin ? "Welcome back!" : "Join the community")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)
                        
                        // Form Card
                        VStack(spacing: 20) {
                            // Toggle between Login/Signup
                            Picker("Mode", selection: $isLogin) {
                                Text("Login").tag(true)
                                Text("Sign Up").tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                            
                            // Username (Signup only)
                            if !isLogin {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Username")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                        
                                        TextField("Enter username", text: $username)
                                            .autocapitalization(.none)
                                            .textContentType(.username)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.gray)
                                    
                                    TextField("Enter email", text: $email)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                        .textContentType(.emailAddress)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Password
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.gray)
                                    
                                    SecureField("Enter password", text: $password)
                                        .textContentType(isLogin ? .password : .newPassword)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Confirm Password (Signup only)
                            if !isLogin {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Confirm Password")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.gray)
                                        
                                        SecureField("Confirm password", text: $confirmPassword)
                                            .textContentType(.newPassword)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Error Message
                            if showError {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Submit Button
                            Button(action: handleSubmit) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(isLogin ? "Login" : "Sign Up")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brown)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isLoading || !isFormValid())
                            .opacity(isFormValid() ? 1.0 : 0.6)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Forgot Password (Login only)
                            if isLogin {
                                Button(action: {
                                    // Handle forgot password
                                    handleForgotPassword()
                                }) {
                                    Text("Forgot Password?")
                                        .font(.subheadline)
                                        .foregroundColor(.brown)
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            MainAppView()
        }
    }
    
    // MARK: - Validation
    
    private func isFormValid() -> Bool {
        if email.isEmpty || password.isEmpty {
            return false
        }
        
        if !isLogin {
            if username.isEmpty || confirmPassword.isEmpty {
                return false
            }
            if password != confirmPassword {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Actions
    
    private func handleSubmit() {
        hideKeyboard()
        showError = false
        errorMessage = ""
        
        if isLogin {
            login()
        } else {
            signup()
        }
    }
    
    private func login() {
        isLoading = true
        let database = Database.database().reference()
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            database.child("users").child((result?.user.uid)!).getData { error, snapShot in
                isLoading = false
                guard error == nil, let userData = snapShot?.value as? [String: Any] else {
                    self.errorMessage = "Failed to get user data:"
                    self.showError = true
                    return
                }
                
                // Save login state
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(email, forKey: "userEmail")
                UserDefaults.standard.set(result?.user.uid, forKey: "userId")
                UserDefaults.standard.set(userData["name"], forKey: "username")
                
                // Navigate to home
                navigateToHome = true
            }
            
            
            
        }
    }
    
    private func signup() {
        isLoading = true
        
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            isLoading = false
            return
        }
        
        // Create account
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            // Save user data to Firebase Database
            guard let userId = result?.user.uid else {
                isLoading = false
                return
            }
            
            saveUserData(userId: userId)
        }
    }
    
    private func saveUserData(userId: String) {
        let userData: [String: Any] = [
            "userId": userId,
            "name": username,  // Android uses "name" not "username"
            "email": email
        ]
        
        // Save to Firebase Realtime Database
        let database = Database.database().reference()
        database.child("users").child(userId).setValue(userData) { error, _ in
            isLoading = false
            
            if let error = error {
                self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                self.showError = true
                return
            }
            
            // Save login state
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(username, forKey: "username")
            UserDefaults.standard.set(userId, forKey: "userId")
            
            // Navigate to home
            navigateToHome = true
        }
    }
    
    private func handleForgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            showError = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                errorMessage = "Password reset email sent!"
                showError = true
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupLoginView()
}
