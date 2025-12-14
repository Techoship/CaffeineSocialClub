//
//  CommentsView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
import FirebaseDatabase

struct Comment: Identifiable, Codable {
    var id: String
    var commentId: String
    var postId: String
    var userId: String
    var userName: String
    var text: String
    var timestamp: Double
    
    enum CodingKeys: String, CodingKey {
        case commentId, postId, userId, userName, text, timestamp
    }
    
    init(id: String, commentId: String, postId: String, userId: String, userName: String, text: String, timestamp: Double) {
        self.id = id
        self.commentId = commentId
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let commentId = try container.decode(String.self, forKey: .commentId)
        self.id = commentId
        self.commentId = commentId
        self.postId = try container.decode(String.self, forKey: .postId)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Double.self, forKey: .timestamp)
    }
    
    var timeAgo: String {
        let now = Date().timeIntervalSince1970
        let difference = now - (timestamp / 1000.0) // Android uses milliseconds
        
        let minutes = Int(difference / 60)
        let hours = Int(difference / 3600)
        let days = Int(difference / 86400)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

struct CommentsView: View {
    let postId: String
    
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    private let database = Database.database().reference()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Comments List
                if isLoading {
                    Spacer()
                    ProgressView("Loading comments...")
                    Spacer()
                } else if comments.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No comments yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Be the first to comment!")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding()
                    }
                }
                
                Divider()
                
                // Comment Input
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: postComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.brown)
                    }
                    .disabled(newCommentText.isEmpty)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadComments()
            }
        }
    }
    
    private func loadComments() {
        database.child("comments").child(postId).observe(.value) { snapshot in
            var loadedComments: [Comment] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any] {
                    
                    let comment = Comment(
                        id: snapshot.key,
                        commentId: dict["commentId"] as? String ?? snapshot.key,
                        postId: dict["postId"] as? String ?? postId,
                        userId: dict["userId"] as? String ?? "",
                        userName: dict["userName"] as? String ?? "Unknown",
                        text: dict["text"] as? String ?? "",
                        timestamp: dict["timestamp"] as? Double ?? 0
                    )
                    loadedComments.append(comment)
                }
            }
            
            self.comments = loadedComments.sorted { $0.timestamp < $1.timestamp }
            self.isLoading = false
        }
    }
    
    private func postComment() {
        guard !newCommentText.isEmpty else { return }
        
        let commentRef = database.child("comments").child(postId).childByAutoId()
        let commentId = commentRef.key ?? ""
        
        // Get current user data from UserDefaults
        let userId = UserDefaults.standard.string(forKey: "userId") ?? "anonymous"
        let userName = UserDefaults.standard.string(forKey: "username") ?? "Anonymous User"
        
        let commentData: [String: Any] = [
            "commentId": commentId,
            "postId": postId,
            "userId": userId,
            "userName": userName,
            "text": newCommentText,
            "timestamp": Date().timeIntervalSince1970 * 1000 // Android uses milliseconds
        ]
        
        commentRef.setValue(commentData) { error, _ in
            if error == nil {
                newCommentText = ""
                
                // Update comment count on the post
                self.updateCommentCount()
            }
        }
    }
    
    private func updateCommentCount() {
        // Get current comment count and increment
        database.child("posts").child(postId).child("commentCount").observeSingleEvent(of: .value) { snapshot in
            let currentCount = snapshot.value as? Int ?? 0
            self.database.child("posts").child(postId).child("commentCount").setValue(currentCount + 1)
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.brown.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(comment.userName.prefix(1).uppercased()))
                        .font(.subheadline)
                        .foregroundColor(.brown)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.userName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(comment.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(comment.text)
                    .font(.body)
            }
        }
    }
}

#Preview {
    CommentsView(postId: "-Oe5gJ7adMtjNPVvPpai")
}
