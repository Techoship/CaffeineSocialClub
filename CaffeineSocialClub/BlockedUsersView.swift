//
//  BlockedUsersView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 19/12/2025.
//

import SwiftUI
import FirebaseDatabase

struct BlockedUser: Identifiable {
    let id: String
    let userId: String
    let username: String
    let timestamp: Double
}

struct BlockedUsersView: View {
    @Environment(\.dismiss) var dismiss
    @State private var blockedUsers: [BlockedUser] = []
    @State private var isLoading = true
    @State private var showUnblockAlert = false
    @State private var userToUnblock: BlockedUser?
    
    private let database = Database.database().reference()
    private var currentUserId: String {
        UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading blocked users...")
                } else if blockedUsers.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No blocked users")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Users you block will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        Section {
                            ForEach(blockedUsers) { user in
                                BlockedUserRow(user: user) {
                                    userToUnblock = user
                                    showUnblockAlert = true
                                }
                            }
                        } header: {
                            Text("You've blocked \(blockedUsers.count) user(s)")
                        } footer: {
                            Text("Blocked users cannot see your content or interact with you.")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Blocked Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Unblock User", isPresented: $showUnblockAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Unblock", role: .destructive) {
                    if let user = userToUnblock {
                        unblockUser(user)
                    }
                }
            } message: {
                Text("Are you sure you want to unblock \(userToUnblock?.username ?? "this user")? They will be able to see and interact with your content again.")
            }
            .onAppear {
                loadBlockedUsers()
            }
        }
    }
    
    private func loadBlockedUsers() {
        guard !currentUserId.isEmpty else {
            isLoading = false
            return
        }
        
        database.child("blockedUsers").child(currentUserId).observeSingleEvent(of: .value) { snapshot in
            var users: [BlockedUser] = []
            
            let group = DispatchGroup()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let data = snapshot.value as? [String: Any],
                   let blockedUserId = data["blockedUserId"] as? String,
                   let timestamp = data["timestamp"] as? Double {
                    
                    group.enter()
                    
                    // Fetch username from users database
                    self.database.child("users").child(blockedUserId).observeSingleEvent(of: .value) { userSnapshot in
                        let username = (userSnapshot.value as? [String: Any])?["name"] as? String ?? "Unknown User"
                        
                        let blockedUser = BlockedUser(
                            id: snapshot.key,
                            userId: blockedUserId,
                            username: username,
                            timestamp: timestamp
                        )
                        users.append(blockedUser)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.blockedUsers = users.sorted { $0.timestamp > $1.timestamp }
                self.isLoading = false
            }
        }
    }
    
    private func unblockUser(_ user: BlockedUser) {
        ContentModerationManager.shared.unblockUser(
            blockedUserId: user.userId,
            blockedBy: currentUserId
        ) { success, message in
            if success {
                // Remove from local list
                blockedUsers.removeAll { $0.id == user.id }
            }
        }
    }
}

struct BlockedUserRow: View {
    let user: BlockedUser
    let onUnblock: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(user.username.prefix(1).uppercased()))
                        .font(.headline)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.username)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text("Blocked \(timeAgo(from: user.timestamp))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onUnblock) {
                Text("Unblock")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func timeAgo(from timestamp: Double) -> String {
        let now = Date().timeIntervalSince1970
        let difference = now - (timestamp / 1000.0)
        
        let days = Int(difference / 86400)
        let hours = Int(difference / 3600)
        let minutes = Int(difference / 60)
        
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

#Preview {
    BlockedUsersView()
}
