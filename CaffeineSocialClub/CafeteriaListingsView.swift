//
//  CafeteriaListingsView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 23/12/2025.
//

import SwiftUI
import Kingfisher

struct Cafeteria: Identifiable {
    let id = UUID()
    let image: String
    let name: String
    let address: String
    let rating: Double
    let hours: [String: String]
    let imageName: String? = nil // Can add asset names if needed
}

struct CafeteriaListingsView: View {
    @Environment(\.dismiss) var dismiss
    
    // Local dummy data
    private let cafeterias: [Cafeteria] = [
        Cafeteria(
            image: "https://firebasestorage.googleapis.com/v0/b/caffine-social-club.firebasestorage.app/o/img-20200830-155919-largejpg.jpg?alt=media&token=c9210b56-1c44-4c21-94fc-7df39ace5899",
            name: "Veintiuno Coffee",
            address: "Fernando el Católico Avenue, 21, 50006 Zaragoza",
            rating: 4.6,
            hours: [
                "Monday": "7:00 AM – 9:00 PM",
                "Tuesday": "7:00 AM – 9:00 PM",
                "Wednesday": "7:00 AM – 9:00 PM",
                "Thursday": "7:00 AM – 9:00 PM",
                "Friday": "7:00 AM – 9:00 PM",
                "Saturday": "8:00 AM – 9:00 PM",
                "Sunday": "8:00 AM – 9:00 PM"
            ]
        ),
        Cafeteria(
            image: "https://firebasestorage.googleapis.com/v0/b/caffine-social-club.firebasestorage.app/o/images.jpeg?alt=media&token=83a3f58f-7de3-4bfd-b2d4-d89cde2cf30d",
            name: "Botanical Cafe",
            address: "Santiago Street, 5, Old Town, 50003 Zaragoza, Spain",
            rating: 4.4,
            hours: [
                "Monday": "8:00 AM – 10:00 PM",
                "Tuesday": "8:00 AM – 10:00 PM",
                "Wednesday": "8:00 AM – 10:00 PM",
                "Thursday": "8:00 AM – 10:00 PM",
                "Friday": "8:00 AM – 11:00 PM",
                "Saturday": "9:00 AM – 11:00 PM",
                "Sunday": "9:00 AM – 10:00 PM"
            ]
        ),
        Cafeteria(
            image: "https://firebasestorage.googleapis.com/v0/b/caffine-social-club.firebasestorage.app/o/348s.jpg?alt=media&token=28131008-d3fb-4f22-b5ea-0cc3f8e85ce1",
            name: "Madrigal Cafe",
            address: "Puerto Rico Street, 41, L'Eixample, 46006 Valencia",
            rating: 4.5,
            hours: [
                "Monday": "7:30 AM – 8:30 PM",
                "Tuesday": "7:30 AM – 8:30 PM",
                "Wednesday": "7:30 AM – 8:30 PM",
                "Thursday": "7:30 AM – 8:30 PM",
                "Friday": "7:30 AM – 9:00 PM",
                "Saturday": "8:00 AM – 9:00 PM",
                "Sunday": "8:30 AM – 8:00 PM"
            ]
        ),
        Cafeteria(
            image: "https://firebasestorage.googleapis.com/v0/b/caffine-social-club.firebasestorage.app/o/Lacaffetteria_terrasse.webp?alt=media&token=170b84e4-87af-49c8-bcee-804b74082af6",
            name: "La Caffetteria",
            address: "Main Street, 15, Madrid",
            rating: 4.7,
            hours: [
                "Monday": "8:00 AM – 9:00 PM",
                "Tuesday": "8:00 AM – 9:00 PM",
                "Wednesday": "8:00 AM – 9:00 PM",
                "Thursday": "8:00 AM – 9:00 PM",
                "Friday": "8:00 AM – 10:00 PM",
                "Saturday": "9:00 AM – 10:00 PM",
                "Sunday": "9:00 AM – 9:00 PM"
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cafeterias")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Discover the best places for your meetups")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Cafeteria cards
                    ForEach(cafeterias) { cafeteria in
                        CafeteriaCard(cafeteria: cafeteria)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct CafeteriaCard: View {
    let cafeteria: Cafeteria
    @State private var isExpanded = true
    
    var body: some View {
        HStack{
            VStack{
                // Cafeteria image placeholder
                KFImage(URL(string: cafeteria.image))
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
            }.padding(.horizontal, 5)
            
            // Cafeteria info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(cafeteria.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text(String(format: "%.1f", cafeteria.rating))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    Text(cafeteria.address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // Hours section
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        Text("Openning Hours:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(.primary)
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(cafeteria.hours.keys.sorted()), id: \.self) { day in
                            HStack {
                                Text(day + ":")
                                    .font(.caption)
                                    .frame(width: 80, alignment: .leading)
                                Text(cafeteria.hours[day] ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
            }.padding(.trailing, 8)
            
        }.padding(.vertical)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 10)
        
    }
}

#Preview {
    CafeteriaListingsView()
}

