//
//  UserPreferencesManager.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 15/12/2025.
//

import Foundation

class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userEmail = "userEmail"
        static let username = "username"
        static let userId = "userId"
    }
    
    // MARK: - Public Properties
    
    var isLoggedIn: Bool {
        get { defaults.bool(forKey: Keys.isLoggedIn) }
        set { defaults.set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    var userEmail: String? {
        get { defaults.string(forKey: Keys.userEmail) }
        set { defaults.set(newValue, forKey: Keys.userEmail) }
    }
    
    var username: String? {
        get { defaults.string(forKey: Keys.username) }
        set { defaults.set(newValue, forKey: Keys.username) }
    }
    
    var userId: String? {
        get { defaults.string(forKey: Keys.userId) }
        set { defaults.set(newValue, forKey: Keys.userId) }
    }
    
    // MARK: - Methods
    
    func saveUserData(userId: String, username: String, email: String) {
        self.userId = userId
        self.username = username
        self.userEmail = email
        self.isLoggedIn = true
    }
    
    func clearUserData() {
        defaults.removeObject(forKey: Keys.isLoggedIn)
        defaults.removeObject(forKey: Keys.userEmail)
        defaults.removeObject(forKey: Keys.username)
        defaults.removeObject(forKey: Keys.userId)
    }
    
    func getCurrentUser() -> (userId: String, username: String)? {
        guard let userId = userId, let username = username else {
            return nil
        }
        return (userId, username)
    }
}
