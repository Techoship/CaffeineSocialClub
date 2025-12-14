//
//  CreatePostView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
import FirebaseDatabase
import PhotosUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var postContent = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isPosting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let database = Database.database().reference()
    private let maxCharacters = 500
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Info
                    HStack {
                        Circle()
                            .fill(Color.brown.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(getUserInitial())
                                    .font(.title3)
                                    .foregroundColor(.brown)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(UserPreferencesManager.shared.username ?? "User")
                                .font(.headline)
                            
                            Text("Share your coffee moment")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Post Content
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $postContent)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if postContent.isEmpty {
                                        Text("What's on your mind?")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 12)
                                            .padding(.top, 16)
                                    }
                                },
                                alignment: .topLeading
                            )
                        
                        HStack {
                            Spacer()
                            Text("\(postContent.count)/\(maxCharacters)")
                                .font(.caption)
                                .foregroundColor(postContent.count > maxCharacters ? .red : .gray)
                        }
                    }
                    .padding(.horizontal)
                    
                 
                    
                    // Error Message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: createPost) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Post")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isPostValid() || isPosting)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getUserInitial() -> String {
        if let username = UserPreferencesManager.shared.username {
            return String(username.prefix(1).uppercased())
        }
        return "U"
    }
    
    private func isPostValid() -> Bool {
        return !postContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && postContent.count <= maxCharacters
    }
    
    private func createPost() {
        guard let userData = UserPreferencesManager.shared.getCurrentUser() else {
            errorMessage = "User not found. Please login again."
            showError = true
            return
        }
        
        isPosting = true
        
        let postRef = database.child("posts").childByAutoId()
        let postId = postRef.key ?? ""
        
        let postData: [String: Any] = [
            "postId": postId,
            "userId": userData.userId,
            "userName": userData.username,
            "text": postContent.trimmingCharacters(in: .whitespacesAndNewlines),
            "timestamp": Date().timeIntervalSince1970 * 1000, // Android uses milliseconds
            "likeCount": 0,
            "commentCount": 0
        ]
        
        postRef.setValue(postData) { error, _ in
            isPosting = false
            
            if let error = error {
                errorMessage = "Failed to create post: \(error.localizedDescription)"
                showError = true
            } else {
                // Successfully posted
                dismiss()
            }
        }
        
        // Note: Image upload to Firebase Storage would go here
        // For now, we're just saving the text content
    }
}

#Preview {
    CreatePostView()
}
