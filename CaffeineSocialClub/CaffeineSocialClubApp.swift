//
//  CaffeineSocialClubApp.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 11/12/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseDatabase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    Database.database().isPersistenceEnabled = true
    return true
  }
}

@main
struct CaffeineSocialClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
        SplashView()
        }
    }
}
