//
//  PostsView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 14/12/2025.
//

import SwiftUI
import FirebaseDatabase

struct Post: Identifiable, Codable {
    var id: String
    var postId: String
    var userId: String
    var userName: String
    var text: String
    var timestamp: Double
    var likeCount: Int
    var commentCount: Int
    
    enum CodingKeys: String, CodingKey {
        case postId, userId, userName, text, timestamp, likeCount, commentCount
    }
    
    init(id: String, postId: String, userId: String, userName: String, text: String, timestamp: Double, likeCount: Int, commentCount: Int) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
        self.likeCount = likeCount
        self.commentCount = commentCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let postId = try container.decode(String.self, forKey: .postId)
        self.id = postId
        self.postId = postId
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.text = try container.decode(String.self, forKey: .text)
        self.timestamp = try container.decode(Double.self, forKey: .timestamp)
        self.likeCount = try container.decode(Int.self, forKey: .likeCount)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
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

struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var showCreatePost = false
    
    private let database = Database.database().reference()
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading posts...")
            } else if posts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No posts yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("Be the first to share something!")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Button(action: { showCreatePost = true }) {
                        Label("Create Post", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.brown)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                        }
                    }
                    .padding()
                }
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCreatePost = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.brown)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
        .onAppear {
            loadPosts()
        }
    }
    
    private func loadPosts() {
        database.child("posts").observe(.value) { snapshot in
            var loadedPosts: [Post] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any] {
                    
                    let post = Post(
                        id: snapshot.key,
                        postId: dict["postId"] as? String ?? snapshot.key,
                        userId: dict["userId"] as? String ?? "",
                        userName: dict["userName"] as? String ?? "Unknown",
                        text: dict["text"] as? String ?? "",
                        timestamp: dict["timestamp"] as? Double ?? 0,
                        likeCount: dict["likeCount"] as? Int ?? 0,
                        commentCount: dict["commentCount"] as? Int ?? 0
                    )
                    loadedPosts.append(post)
                }
            }
            
            self.posts = loadedPosts.sorted { $0.timestamp > $1.timestamp }
            self.isLoading = false
        }
    }
}

struct PostCard: View {
    let post: Post
    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    
    private let database = Database.database().reference()
    private var currentUserId: String {
        UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    init(post: Post) {
        self.post = post
        _likeCount = State(initialValue: post.likeCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User Info
            HStack {
                Circle()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.userName.prefix(1).uppercased()))
                            .font(.headline)
                            .foregroundColor(.brown)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName)
                        .font(.headline)
                    
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Post Content
            Text(post.text)
                .font(.body)
            
            // Actions
            HStack(spacing: 20) {
                Button(action: toggleLike) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(likeCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .foregroundColor(.gray)
                        Text("\(post.commentCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showComments) {
            CommentsView(postId: post.postId)
        }
        .onAppear {
            checkIfLiked()
        }
    }
    
    private func checkIfLiked() {
        guard !currentUserId.isEmpty else { return }
        
        // Check if user has liked this post
        database.child("likes").child(post.postId).child(currentUserId).observeSingleEvent(of: .value) { snapshot in
            isLiked = snapshot.exists()
        }
    }
    
    private func toggleLike() {
        guard !currentUserId.isEmpty else { return }
        
        isLiked.toggle()
        let newCount = isLiked ? likeCount + 1 : likeCount - 1
        likeCount = newCount
        
        if isLiked {
            // Add like
            database.child("likes").child(post.postId).child(currentUserId).setValue(true)
        } else {
            // Remove like
            database.child("likes").child(post.postId).child(currentUserId).removeValue()
        }
        
        // Update like count on post
        database.child("posts").child(post.postId).child("likeCount").setValue(newCount)
    }
}

#Preview {
    PostsView()
}
