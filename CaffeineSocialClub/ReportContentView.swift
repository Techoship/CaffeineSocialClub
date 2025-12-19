//
//  ReportContentView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 19/12/2025.
//

import SwiftUI

enum ReportType {
    case post(postId: String)
    case comment(postId: String, commentId: String)
    case user(userId: String, username: String)
}

struct ReportContentView: View {
    @Environment(\.dismiss) var dismiss
    let reportType: ReportType
    
    @State private var selectedReason = "Select a reason"
    @State private var additionalDetails = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    private let reportReasons = [
        "Harassment or bullying",
        "Hate speech or discrimination",
        "Spam or misleading content",
        "Inappropriate or offensive content",
        "Violence or dangerous content",
        "Sexual content",
        "False information",
        "Other"
    ]
    
    private var currentUserId: String {
        UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if showSuccess {
                    SuccessView(message: "Report submitted successfully. We'll review it within 24 hours.") {
                        dismiss()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Report Content")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(headerDescription)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            // Reason Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reason for Report")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Menu {
                                    ForEach(reportReasons, id: \.self) { reason in
                                        Button(action: {
                                            selectedReason = reason
                                        }) {
                                            HStack {
                                                Text(reason)
                                                if selectedReason == reason {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedReason)
                                            .foregroundColor(selectedReason == "Select a reason" ? .gray : .primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Additional Details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Additional Details (Optional)")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                TextEditor(text: $additionalDetails)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .padding(.horizontal)
                            }
                            
                            // Information Box
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("What happens next?")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        Text("Our moderation team reviews all reports within 24 hours. Violators will be removed immediately.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            // Error Message
                            if showError {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            // Submit Button
                            Button(action: submitReport) {
                                HStack {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "flag.fill")
                                        Text("Submit Report")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canSubmit ? Color.red : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(!canSubmit || isSubmitting)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerDescription: String {
        switch reportType {
        case .post:
            return "Help us keep Caffeine Social Club safe by reporting content that violates our community guidelines."
        case .comment:
            return "Report this comment if it contains inappropriate or offensive content."
        case .user:
            return "Report this user if they've been harassing, bullying, or violating community guidelines."
        }
    }
    
    private var canSubmit: Bool {
        selectedReason != "Select a reason" && !currentUserId.isEmpty
    }
    
    private func submitReport() {
        guard canSubmit else { return }
        
        isSubmitting = true
        showError = false
        errorMessage = ""
        
        let reason = selectedReason + (additionalDetails.isEmpty ? "" : " - \(additionalDetails)")
        
        switch reportType {
        case .post(let postId):
            ContentModerationManager.shared.reportPost(
                postId: postId,
                reportedBy: currentUserId,
                reason: reason
            ) { success, message in
                handleReportResult(success: success, message: message)
            }
            
        case .comment(let postId, let commentId):
            ContentModerationManager.shared.reportComment(
                postId: postId,
                commentId: commentId,
                reportedBy: currentUserId,
                reason: reason
            ) { success, message in
                handleReportResult(success: success, message: message)
            }
            
        case .user(let userId, _):
            ContentModerationManager.shared.reportUser(
                userId: userId,
                reportedBy: currentUserId,
                reason: reason
            ) { success, message in
                handleReportResult(success: success, message: message)
            }
        }
    }
    
    private func handleReportResult(success: Bool, message: String) {
        isSubmitting = false
        
        if success {
            showSuccess = true
            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        } else {
            errorMessage = message
            showError = true
        }
    }
}

struct SuccessView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Report Submitted")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ReportContentView(reportType: .post(postId: "test123"))
}
