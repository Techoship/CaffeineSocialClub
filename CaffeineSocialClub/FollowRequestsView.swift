//
//  FollowRequestsView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 23/12/2025.
//

import SwiftUI

struct FollowRequest: Identifiable {
    let id = UUID()
    let userId: String
    let userName: String
    let timeAgo: String
}

struct FollowRequestsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var requests: [FollowRequest] = [
        FollowRequest(userId: "1", userName: "Maria", timeAgo: "2 hours ago"),
        FollowRequest(userId: "2", userName: "Carlos", timeAgo: "5 hours ago"),
        FollowRequest(userId: "3", userName: "Laura", timeAgo: "1 day ago")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                if requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Requests")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Follow requests will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(requests) { request in
                            FollowRequestRow(
                                request: request,
                                onAccept: {
                                    acceptRequest(request)
                                },
                                onReject: {
                                    rejectRequest(request)
                                }
                            )
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Follow Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func acceptRequest(_ request: FollowRequest) {
        withAnimation {
            requests.removeAll { $0.id == request.id }
        }
    }
    
    private func rejectRequest(_ request: FollowRequest) {
        withAnimation {
            requests.removeAll { $0.id == request.id }
        }
    }
}

struct FollowRequestRow: View {
    let request: FollowRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            Circle()
                .fill(Color.brown.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(request.userName.prefix(1).uppercased()))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.brown)
                )
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(request.userName)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Text(request.timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                // Reject button
                Button(action: onReject) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Accept button
                Button(action: onAccept) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(width: 36, height: 36)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FollowRequestsView()
}
