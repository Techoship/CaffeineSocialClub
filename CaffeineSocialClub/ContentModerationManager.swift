//
//  ContentModerationManager.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 19/12/2025.
//

import Foundation
import FirebaseDatabase

class ContentModerationManager {
    static let shared = ContentModerationManager()
    private let database = Database.database().reference()
    
    private init() {}
    
    // MARK: - Report Content
    
    /// Report a post for objectionable content
    func reportPost(postId: String, reportedBy: String, reason: String, completion: @escaping (Bool, String) -> Void) {
        let reportId = database.child("reports").child("posts").childByAutoId().key ?? UUID().uuidString
        
        let reportData: [String: Any] = [
            "reportId": reportId,
            "postId": postId,
            "reportedBy": reportedBy,
            "reason": reason,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "status": "pending",
            "type": "post"
        ]
        
        database.child("reports").child("posts").child(reportId).setValue(reportData) { error, _ in
            if let error = error {
                completion(false, "Failed to submit report: \(error.localizedDescription)")
            } else {
                // Also increment report count on the post for quick filtering
                self.database.child("posts").child(postId).child("reportCount").getData { error, snapshot in
                    let currentCount = snapshot?.value as? Int ?? 0
                    self.database.child("posts").child(postId).child("reportCount").setValue(currentCount + 1)
                }
                completion(true, "Report submitted successfully. We'll review it within 24 hours.")
            }
        }
    }
    
    /// Report a comment for objectionable content
    func reportComment(postId: String, commentId: String, reportedBy: String, reason: String, completion: @escaping (Bool, String) -> Void) {
        let reportId = database.child("reports").child("comments").childByAutoId().key ?? UUID().uuidString
        
        let reportData: [String: Any] = [
            "reportId": reportId,
            "postId": postId,
            "commentId": commentId,
            "reportedBy": reportedBy,
            "reason": reason,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "status": "pending",
            "type": "comment"
        ]
        
        database.child("reports").child("comments").child(reportId).setValue(reportData) { error, _ in
            if let error = error {
                completion(false, "Failed to submit report: \(error.localizedDescription)")
            } else {
                completion(true, "Report submitted successfully. We'll review it within 24 hours.")
            }
        }
    }
    
    /// Report a user for abusive behavior
    func reportUser(userId: String, reportedBy: String, reason: String, completion: @escaping (Bool, String) -> Void) {
        let reportId = database.child("reports").child("users").childByAutoId().key ?? UUID().uuidString
        
        let reportData: [String: Any] = [
            "reportId": reportId,
            "userId": userId,
            "reportedBy": reportedBy,
            "reason": reason,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "status": "pending",
            "type": "user"
        ]
        
        database.child("reports").child("users").child(reportId).setValue(reportData) { error, _ in
            if let error = error {
                completion(false, "Failed to submit report: \(error.localizedDescription)")
            } else {
                completion(true, "User reported successfully. We'll review it within 24 hours.")
            }
        }
    }
    
    // MARK: - Block Users
    
    /// Block a user
    func blockUser(blockedUserId: String, blockedBy: String, completion: @escaping (Bool, String) -> Void) {
        let blockData: [String: Any] = [
            "blockedUserId": blockedUserId,
            "blockedBy": blockedBy,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Store in blocked users list under current user
        database.child("blockedUsers").child(blockedBy).child(blockedUserId).setValue(blockData) { error, _ in
            if let error = error {
                completion(false, "Failed to block user: \(error.localizedDescription)")
            } else {
                // Notify moderation system of the block
                let reportId = self.database.child("reports").child("blocks").childByAutoId().key ?? UUID().uuidString
                let blockReportData: [String: Any] = [
                    "reportId": reportId,
                    "blockedUserId": blockedUserId,
                    "blockedBy": blockedBy,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                    "type": "block"
                ]
                self.database.child("reports").child("blocks").child(reportId).setValue(blockReportData)
                
                completion(true, "User blocked successfully. You won't see their content anymore.")
            }
        }
    }
    
    /// Unblock a user
    func unblockUser(blockedUserId: String, blockedBy: String, completion: @escaping (Bool, String) -> Void) {
        database.child("blockedUsers").child(blockedBy).child(blockedUserId).removeValue { error, _ in
            if let error = error {
                completion(false, "Failed to unblock user: \(error.localizedDescription)")
            } else {
                completion(true, "User unblocked successfully.")
            }
        }
    }
    
    /// Check if a user is blocked by current user
    func isUserBlocked(userId: String, blockedBy: String, completion: @escaping (Bool) -> Void) {
        database.child("blockedUsers").child(blockedBy).child(userId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    /// Get list of blocked users for current user
    func getBlockedUsers(currentUserId: String, completion: @escaping ([String]) -> Void) {
        database.child("blockedUsers").child(currentUserId).observeSingleEvent(of: .value) { snapshot in
            var blockedUserIds: [String] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    blockedUserIds.append(snapshot.key)
                }
            }
            
            completion(blockedUserIds)
        }
    }
    
    // MARK: - Content Filtering
    
    /// Filter posts to exclude content from blocked users
    func filterBlockedContent(posts: [Post], currentUserId: String, completion: @escaping ([Post]) -> Void) {
        getBlockedUsers(currentUserId: currentUserId) { blockedUserIds in
            let filteredPosts = posts.filter { post in
                !blockedUserIds.contains(post.userId)
            }
            completion(filteredPosts)
        }
    }
}
