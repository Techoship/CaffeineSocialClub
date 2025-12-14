//
//  HomeView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import SwiftUI
internal import Combine

struct HomeView: View {
    @State private var currentImageIndex = 0
    private let bannerImages = ["img_banner1", "img_banner2", "img_banner3"]
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Image("ic_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("Caffeine Social Club")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Text("GOODBY ENDLESS CHATS")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                Text("HELLO REAL MEETUPS")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.red)
                
                Text("Say goodbye to fake profiles and endless messaging. Meet real coffee lovers in local cafés and turn a coffee into a genuine experience.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<bannerImages.count, id: \.self) { index in
                        Image(bannerImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                            .tag(index)
                    }
                }
                .frame(height: 200)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .onReceive(timer) { _ in
                    withAnimation {
                        currentImageIndex = (currentImageIndex + 1) % bannerImages.count
                    }
                }.padding(.vertical)
                Text("The new way to connect that is already trending in Madrid and Barcelona")
                    .font(.body)
                    .foregroundColor(.gray)
            
                
                Text("THE PIONEERS OF COFFEE COMMUNITY IN SPAIN")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
                Text("While other apps keep you stuck on your screen, the first users of Caffeine Social Club are rediscovering the joy of real connections. Choose verified local cafés and enjoy safe, authentic meetups from day one.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.bottom)
             
                FeatureCard(icon: "heart.fill", title: "Authentic Connections", color: .red)
                
                FeatureCard(icon: "cup.and.heat.waves.fill", title: "Exclusive Caffee talks", color: .brown)
                FeatureCard(icon: "person.2", title: "Community", color: .orange)
                FeatureCard(icon: "hand.thumbsup.fill", title: "Like", color: .red)
                FeatureCard(icon: "message.fill", title: "Comments", color: .blue)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
}
