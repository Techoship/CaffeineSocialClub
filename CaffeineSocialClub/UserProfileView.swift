//
//  UserProfileView.swift
//  CaffeineSocialClub
//
//  Created by MSulmanGull on 23/12/2025.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import Kingfisher

struct UserProfile: Codable {
    var userId: String
    var name: String
    var email: String
    var profileImageUrl: String?
    var bio: String?
    var interests: [String]?
    var dateOfBirth: String?
    var city: String?
    var gender: String?
}

struct UserProfileView: View {
    let userId: String
    let userName: String
    let isOwnProfile: Bool // true if viewing own profile
    
    @Environment(\.dismiss) var dismiss
    @State private var userProfile: UserProfile?
    @State private var isFollowing = false
    @State private var followRequestSent = false
    @State private var showSuccessMessage = false
    @State private var isLoading = true
    
    // Edit mode
    @State private var isEditMode = false
    @State private var editBio = ""
    @State private var editCity = ""
    @State private var editGender = "Male"
    @State private var editDateOfBirth = Date()
    @State private var editInterests: [String] = []
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    private var currentUserId: String {
        UserDefaults.standard.string(forKey: "userId") ?? ""
    }
    
    private let availableInterests = ["Coffee", "Books", "Tennis", "Music", "Travel", "Sports", "Movies", "Runing", "Cooking", "Driving", "Yoga", "Hiking"]
    private let genderOptions = ["Male", "Female", "Other"]
    
    init(userId: String, userName: String, isOwnProfile: Bool = false) {
        self.userId = userId
        self.userName = userName
        self.isOwnProfile = isOwnProfile
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 30)
                if !isEditMode {
                ZStack (alignment: .topTrailing){
                        if let imageUrl = userProfile?.profileImageUrl, !imageUrl.isEmpty {
                            KFImage(URL(string: imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 350)
                                .padding(.horizontal)
                            .clipShape(RoundedRectangle(cornerRadius: 10,))
                            .overlay(RoundedRectangle(cornerRadius: 15,).stroke(Color.white, lineWidth: 4))
                        } else {
                            RoundedRectangle(cornerRadius: 15,)
                                .fill(Color.accentColor.opacity(0.3))
                                .frame(width: 350, height: 350)
                                .padding(.horizontal)
                                .overlay(
                                    Text(String(userName.prefix(1).uppercased()))
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                )
                                .overlay(RoundedRectangle(cornerRadius: 15,).stroke(Color.white, lineWidth: 4))
                        }
                    if let dob = userProfile?.dateOfBirth {
                        Text(zodiacSign(from: dob)!)
                            .font(.system(size: 10))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background {
                                Capsule()
                                    .fill(Color.white)
                            }
                            .padding(10)
                    }
                    }
                    
                }
                // Header with profile image
                
                if isEditMode{
                    ZStack(alignment: .bottom) {
                        // Background gradient
                        LinearGradient(
                            colors: [Color.accent.opacity(0.3), Color.white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 250)
                        
                        // Profile image
                        ZStack(alignment: .bottomTrailing) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } else if let imageUrl = userProfile?.profileImageUrl, !imageUrl.isEmpty {
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.3))
                                        .overlay(
                                            Text(String(userName.prefix(1).uppercased()))
                                                .font(.system(size: 50))
                                                .fontWeight(.bold)
                                                .foregroundColor(.accentColor)
                                        )
                                }
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            } else {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Text(String(userName.prefix(1).uppercased()))
                                            .font(.system(size: 50))
                                            .fontWeight(.bold)
                                            .foregroundColor(.accentColor)
                                    )
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            }
                            
                            // Camera button for own profile
                            if isOwnProfile && (isEditMode || userProfile?.profileImageUrl == nil) {
                                Button(action: { showingImagePicker = true }) {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        )
                                }
                                .offset(x: -5, y: -5)
                            }
                        }
                        
                    }
                }
                
                // User info
                VStack(spacing: 12) {
                    if !isEditMode {
                        HStack{
                            Text(userName)
                                .font(.title)
                                .fontWeight(.bold)
                            if let dob = userProfile?.dateOfBirth {
                                Text(", \(calculateAge(from: dob).split(separator: " ").first!)")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }.padding(.top, 20)
                            .padding(.horizontal)
                    }
                    
                    
                    if !isEditMode {
                        // Display mode
                        HStack(spacing: 20) {
                            if let city = userProfile?.city {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.accentColor)
                                    Text(city)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                            
                            if let gender = userProfile?.gender {
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.accentColor)
                                    Text(gender)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }.padding(.horizontal)
                    } else {
                        // Edit mode
                        VStack(spacing: 12) {
                            // City input
                            VStack(alignment: .leading, spacing: 4) {
                                Text("City")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("Valencia", text: $editCity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding(.horizontal)
                            
                            // Gender picker
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Gender")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Picker("Gender", selection: $editGender) {
                                    ForEach(genderOptions, id: \.self) { gender in
                                        Text(gender).tag(gender)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            .padding(.horizontal)
                            
                            // Date of birth picker
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Date of Birth")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $editDateOfBirth, in: ...Date(), displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    
//                     else {
//                        // Follow button for other users
//                        Button(action: sendFollowRequest) {
//                            HStack {
//                                Image(systemName: followRequestSent ? "checkmark.circle.fill" : "heart.fill")
//                                Text(followRequestSent ? "Request Sent" : "Follow")
//                                    .fontWeight(.semibold)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(followRequestSent ? Color.gray : Color.brown)
//                            .foregroundColor(.white)
//                            .cornerRadius(25)
//                        }
//                        .disabled(followRequestSent)
//                        .padding(.horizontal, 40)
//                        .padding(.top, 10)
//                    }
                }
                
                // Bio section
                VStack(alignment: .leading, spacing: 16) {
                    if !isEditMode {
                        if let bio = userProfile?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 20)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bio")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            TextEditor(text: $editBio)
                                .frame(height: 100)
                                .padding(8)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                    }
                    
                    // Interests
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interests")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !isEditMode {
                            if let interests = userProfile?.interests, !interests.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(interests, id: \.self) { interest in
                                            InterestChip(text: interest, isSelected: true, onTap: {})
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                Text("No interests added")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        } else {
                            // Edit mode - selectable interests
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(availableInterests, id: \.self) { interest in
                                    InterestChip(
                                        text: interest,
                                        isSelected: editInterests.contains(interest),
                                        onTap: {
                                            if editInterests.contains(interest) {
                                                editInterests.removeAll { $0 == interest }
                                            } else {
                                                editInterests.append(interest)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
                
                // Action buttons
                if isOwnProfile {
                    HStack(spacing: 12) {
                        if isEditMode {
                            Button(action: cancelEdit) {
                                Text("Cancel")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(25)
                            }
                            
                            Button(action: saveProfile) {
                                HStack {
                                    if isUploading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Save")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                            }
                            .disabled(isUploading)
                        } else {
                            Button(action: { isEditMode = true }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 30)
                }
                
                Spacer(minLength: 40)
            }
        }
        .overlay(
            Group {
                if showSuccessMessage {
                    VStack {
                        Spacer()
                        Text(isOwnProfile ? "Profile updated!" : "Follow request sent!")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
        )
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        database.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                isLoading = false
                return
            }
            
            userProfile = UserProfile(
                userId: userId,
                name: data["name"] as? String ?? userName,
                email: data["email"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String,
                bio: data["bio"] as? String,
                interests: data["interests"] as? [String],
                dateOfBirth: data["dateOfBirth"] as? String,
                city: data["city"] as? String,
                gender: data["gender"] as? String
            )
            
            // Initialize edit fields
            editBio = userProfile?.bio ?? ""
            editCity = userProfile?.city ?? ""
            editGender = userProfile?.gender ?? "Male"
            editInterests = userProfile?.interests ?? []
            
            if let dobString = userProfile?.dateOfBirth {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: dobString) {
                    editDateOfBirth = date
                }
            }
            
            isLoading = false
        }
    }
    
    private func saveProfile() {
        isUploading = true
        
        // Upload image if selected
        if let selectedImage = selectedImage {
            uploadImage(selectedImage) { imageUrl in
                updateProfileData(imageUrl: imageUrl)
            }
        } else {
            updateProfileData(imageUrl: userProfile?.profileImageUrl)
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let imageName = "\(userId)_\(UUID().uuidString).jpg"
        let imageRef = storage.child("profile_images/\(imageName)")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                completion(url?.absoluteString)
            }
        }
    }
    
    func zodiacSign(from dobString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = formatter.date(from: dobString) else {
            return nil
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: date)

        guard let day = components.day, let month = components.month else {
            return nil
        }

        switch (month, day) {
        case (3, 21...31), (4, 1...19):
            return "♈ Aries"
        case (4, 20...30), (5, 1...20):
            return "♉ Taurus"
        case (5, 21...31), (6, 1...20):
            return "♊ Gemini"
        case (6, 21...30), (7, 1...22):
            return "♋ Cancer"
        case (7, 23...31), (8, 1...22):
            return "♌ Leo"
        case (8, 23...31), (9, 1...22):
            return "♍ Virgo"
        case (9, 23...30), (10, 1...22):
            return "♎ Libra"
        case (10, 23...31), (11, 1...21):
            return "♏ Scorpio"
        case (11, 22...30), (12, 1...21):
            return "♐ Sagittarius"
        case (12, 22...31), (1, 1...19):
            return "♑ Capricorn"
        case (1, 20...31), (2, 1...18):
            return "♒ Aquarius"
        case (2, 19...29), (3, 1...20):
            return "♓ Pisces"
        default:
            return nil
        }
    }
    
    private func updateProfileData(imageUrl: String?) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dobString = formatter.string(from: editDateOfBirth)
        
        var updates: [String: Any] = [
            "bio": editBio,
            "city": editCity,
            "gender": editGender,
            "dateOfBirth": dobString,
            "interests": editInterests
        ]
        
        if let imageUrl = imageUrl {
            updates["profileImageUrl"] = imageUrl
        }
        
        database.child("users").child(userId).updateChildValues(updates) { error, _ in
            isUploading = false
            
            if error == nil {
                // Update local profile
                userProfile?.bio = editBio
                userProfile?.city = editCity
                userProfile?.gender = editGender
                userProfile?.dateOfBirth = dobString
                userProfile?.interests = editInterests
                if let imageUrl = imageUrl {
                    userProfile?.profileImageUrl = imageUrl
                }
                
                // Also update UserDefaults if own profile
                if isOwnProfile {
                    UserDefaults.standard.set(editCity, forKey: "userCity")
                    UserDefaults.standard.set(editGender, forKey: "userGender")
                    UserDefaults.standard.set(dobString, forKey: "userDOB")
                }
                
                isEditMode = false
                showSuccessMessage = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSuccessMessage = false
                    }
                }
            }
        }
    }
    
    private func cancelEdit() {
        // Reset edit fields
        editBio = userProfile?.bio ?? ""
        editCity = userProfile?.city ?? ""
        editGender = userProfile?.gender ?? "Male"
        editInterests = userProfile?.interests ?? []
        selectedImage = nil
        
        if let dobString = userProfile?.dateOfBirth {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dobString) {
                editDateOfBirth = date
            }
        }
        
        isEditMode = false
    }
    
    private func sendFollowRequest() {
        followRequestSent = true
        showSuccessMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSuccessMessage = false
            }
        }
    }
    
    private func calculateAge(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let birthDate = formatter.date(from: dateString) else {
            return ""
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        
        if let age = ageComponents.year {
            return "\(age) years"
        }
        
        return ""
    }
}

struct InterestChip: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(text)
                    .font(.system(size: 10))
                    .fontWeight(.regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.orange.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .black : .gray)
            .cornerRadius(20)
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        UserProfileView(userId: "test123", userName: "Antonio", isOwnProfile: true)
    }
}
