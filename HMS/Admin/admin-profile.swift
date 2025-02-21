///  Admin.swift profile
//  HMS
//

import SwiftUI
import Firebase

struct AdminDetails {
    var name: String
    var email: String
    var contact: String
    // Add more properties if needed
}

struct AdminProfile: View {
   
    @State private var showAlert = false
    @EnvironmentObject var userTypeManager: UserTypeManager

    let admin: AdminDetails
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        // Profile Image
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                        
                        // Admin Details
                        VStack(alignment: .leading, spacing: 8) {
                            Text(admin.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Email: \(admin.email)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Phone: \(admin.contact)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                    .padding(.horizontal, 20)
                    
                    // Buttons
             
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.bottom, 50) // Add padding at the bottom for the logout button
            }
            
            // Logout Button
            LogoutButton(showAlert: $showAlert )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: .default(Text("Yes")) {
                logout()
            }, secondaryButton: .cancel())
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut() // Sign out from Firebase authentication

            // Reset user defaults
            UserDefaults.standard.removeObject(forKey: "userType")
            UserDefaults.standard.removeObject(forKey: "userID")
            
            // Reset environment objects
            userTypeManager.userType = .unknown
            userTypeManager.userID = ""

            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Handle errors if necessary, e.g., show an alert
        }
    }
}

struct AdminProfile_Previews: PreviewProvider {
    static var previews: some View {
        let admin = AdminDetails(name: "Admin Name", email: "admin@example.com", contact: "123-456-7890")
        return AdminProfile(admin: admin)
    }
}
