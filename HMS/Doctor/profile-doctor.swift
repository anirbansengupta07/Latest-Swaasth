import SwiftUI
import Firebase

struct DoctorAccountView: View {
    
    @State private var doctor: DoctorModel?
        @State private var showAlert = false
        @EnvironmentObject var userTypeManager: UserTypeManager

        var body: some View {
            NavigationView {
                VStack {
                    if let doctor = doctor {
                        ProfileDoctorHeaderView(doctor: doctor)
                    } else {
                        ProgressView("Loading...")
                    }
                    
                    Spacer() // Add spacer to push logout button to the bottom
                    
                    LogoutButton(showAlert: $showAlert)
                }
                .padding(.leading)
                .padding(.trailing)
                .background(Color(.systemGroupedBackground)) // Set background color
                .navigationBarTitle("My Account")
                .onAppear {
                    fetchDoctorData()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: .default(Text("Yes")) {
                        logout()
                    }, secondaryButton: .cancel())
                }
            }
        }
        
    func fetchDoctorData() {
        let db = Firestore.firestore()
        let ref = db.collection("doctors")
        
        // Query for documents where the "authID" field is equal to userTypeManager.userID
        ref.whereField("authID", isEqualTo: userTypeManager.userID)
            .getDocuments { (snapshot, error) in
                
                // Check for errors
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return // Exit early
                }
                
                // Check if there are any documents
                guard let snapshot = snapshot else {
                    print("No documents")
                    return // Exit early
                }
                
                // Iterate over the documents
                for document in snapshot.documents {
                    let data = document.data() // Get the document data
                    let doctor = DoctorModel(from: data, id: document.documentID)
                    self.doctor = doctor // Update the doctor property
                }
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

struct ProfileDoctorHeaderView: View {
    var doctor: DoctorModel

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.customBlue.opacity(0.5), Color.customBlue.opacity(1)]),
                        startPoint: .leading,
                        endPoint: .trailing))
                    .frame(height: 160) // Adjusted height
                    .shadow(color: Color.black.opacity(0.15), radius: 20)
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 10)
                        .foregroundColor(.white)
                    VStack(alignment: .leading) {
                       
                        Text(" \(doctor.name)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(doctor.specialisation)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                                .frame(height: 2)

                        if let id = doctor.id {
                            Text("Doc ID: \(id)")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            Spacer()
                                    .frame(height: 2)
                        }
                        Text("Cabin Number: \(doctor.cabinNumber)")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
            }
            
            VStack(alignment: .leading) {
                HStack{
                    Text("Details" )
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "pencil")
                        .foregroundColor(.black)
                        .padding()
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Email:")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            
                        Spacer()
                            .frame(height: 10)
                        Text("Phone Number:")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                            .frame(height: 10)
                        Text("Degree:")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                            .frame(height: 10)
                        Text("Experience:")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    VStack(alignment: .leading) {
                        Text(doctor.email ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                            .frame(height: 10)
                        Text(doctor.contact ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                            .frame(height: 10)
                        Text(doctor.degree ?? "")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                            .frame(height: 10)
                        Text("\(doctor.experience ?? "") Years")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }

                }

                          
        }
        .padding(.vertical) // Add vertical padding
    }
}
//
struct DoctorAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let userTypeManager = UserTypeManager() // Create an instance of UserTypeManager
        userTypeManager.userID = "your_user_id_here" // Set the user ID

        return DoctorAccountView()
            .environmentObject(userTypeManager) // Inject the environment object
    }
}
