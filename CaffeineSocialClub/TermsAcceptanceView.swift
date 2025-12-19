//
//  TermsAcceptanceView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 19/12/2025.
//

import SwiftUI

struct TermsAcceptanceView: View {
    @Binding var hasAcceptedTerms: Bool
    @State private var showTermsDetail = false
    @State private var agreedToTerms = false
    
    var body: some View {
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
                        
                        Text("Welcome to")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Caffeine Social Club")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 20)
                    
                    // Terms Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Community Guidelines")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Before you start connecting with people over coffee, please review and accept our community standards:")
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        // Key Points
                        VStack(alignment: .leading, spacing: 16) {
                            GuidelinePoint(
                                icon: "hand.raised.fill",
                                title: "Zero Tolerance Policy",
                                description: "We have zero tolerance for objectionable content, harassment, hate speech, or abusive behavior."
                            )
                            
                            GuidelinePoint(
                                icon: "shield.checkered",
                                title: "Safe Community",
                                description: "Help us maintain a safe space by reporting inappropriate content or users."
                            )
                            
                            GuidelinePoint(
                                icon: "exclamationmark.triangle.fill",
                                title: "Swift Action",
                                description: "Reported content is reviewed within 24 hours. Violators will be removed immediately."
                            )
                            
                            GuidelinePoint(
                                icon: "person.2.slash",
                                title: "Block & Report",
                                description: "You can block users and report content at any time to keep your experience positive."
                            )
                        }
                        
                        // Legal Links
                        VStack(spacing: 12) {
                            Button(action: openTermsOfService) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(.brown)
                                    Text("Read Full Terms of Service")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.brown)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            
                            Button(action: openPrivacyPolicy) {
                                HStack {
                                    Image(systemName: "hand.raised.fill")
                                        .foregroundColor(.brown)
                                    Text("Read Privacy Policy")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.brown)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Checkbox Agreement
                        Button(action: { agreedToTerms.toggle() }) {
                            HStack(spacing: 12) {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundColor(agreedToTerms ? .brown : .gray)
                                
                                Text("I have read and agree to the Terms of Service, Privacy Policy, and Community Guidelines")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Accept Button
                        Button(action: acceptTerms) {
                            Text("Accept & Continue")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(agreedToTerms ? Color.brown : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!agreedToTerms)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func acceptTerms() {
        guard agreedToTerms else { return }
        
        // Save acceptance to UserDefaults with timestamp
        UserDefaults.standard.set(true, forKey: "hasAcceptedTerms")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "termsAcceptedTimestamp")
        UserDefaults.standard.set("1.0", forKey: "termsVersionAccepted")
        
        hasAcceptedTerms = true
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://sites.google.com/view/caffeine-social-club-tos/home") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://sites.google.com/view/caffeine-social-club-privacy/home") {
            UIApplication.shared.open(url)
        }
    }
}

struct GuidelinePoint: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.brown)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    TermsAcceptanceView(hasAcceptedTerms: .constant(false))
}
