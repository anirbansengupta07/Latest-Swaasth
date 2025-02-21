//  profile-patient.swift
//  HMS
//

import SwiftUI
import Firebase

struct PatientProfileView: View {
    @State private var isEditingProfile = false
    @State private var showAlert = false
    @EnvironmentObject var userTypeManager: UserTypeManager

    @State private var patient = PatientModel()

    var body: some View {
    
            NavigationView {
                
                VStack {            
                    ProfileHeaderView(patient: patient)
                    Spacer()
                    
                    
                    
                    NavigationLink(destination: HealthRecordAdd()) {
                        Text("View Records")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.customBlue)
                            .foregroundColor(.white)
                            .cornerRadius(11)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    LogoutButton(showAlert:$showAlert)
                }
                .padding() // Add padding to the VStack
                .background(Color(.systemGroupedBackground)) // Set background color
                .navigationBarTitle("My Account")
                .onAppear {
                    fetchPatientData()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Logout"), message: Text("Are you sure you want to logout?"), primaryButton: .default(Text("Yes")) {
                        logout()
                    }, secondaryButton: .cancel())
                }
            }
        
    }
    
    func fetchPatientData() {
        let db = Firestore.firestore()
        db.collection("Patients").document(userTypeManager.userID).getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data() {
                    patient = PatientModel(dictionary: data, id: document.documentID)!
                }
            } else {
                print("Document does not exist")
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

struct ProfileHeaderView: View {
    var patient: PatientModel
    
    @State private var showEditSheet: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.customBlue.opacity(0.5), Color.customBlue.opacity(1)]),
                        startPoint: .leading,
                        endPoint: .trailing))
                    .frame(height: 150) // Adjusted height
                    .shadow(color: Color.black.opacity(0.15), radius: 20)
                HStack {
                    Spacer()
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.trailing, 10)
                        .foregroundColor(.white)
                    VStack(alignment: .leading) {
                        if let name = patient.name {
                            Text(name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                        }
                        if let id = patient.id {
                            Text("Patient ID: \(id)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        if let gender = patient.gender {
                            Text("Gender: \(gender.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
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
                    Button {
                        showEditSheet.toggle()
                    } label: {
                        Image(systemName: "pencil")
                        .foregroundColor(.black)
                        .padding()
                    }
                        
                }
                if let email = patient.email {
                    Text("Email: \(email)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                if let address = patient.address {
                    Text("Address: \(address)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                if let phoneNumber = patient.contact {
                    Text("Phone: \(phoneNumber)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
        
            
        }
        .padding(.vertical) // Add vertical padding

        .sheet(isPresented: $showEditSheet) {
            editPatientDetails(patientData: patient, showEditSheet: $showEditSheet)
        }

    }
}

struct SectionView: View {
    var icon: Image
    var title: String
    var subtitle: String
    
    
    var body: some View {
        
            VStack {

                Divider()
                    .background(Color.gray)
                    .frame(width: 400)
                HStack {
                    
                    
                    icon
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 30, height: 30)
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.headline)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .ignoresSafeArea()
                .padding()
                .frame(width: 400)
             
                Divider()
                    .background(Color.gray)
                    .frame(width: 400)
            }
            
            .background(Color.white)
          
            
        
        
    }
}

struct LogoutButton: View {
    @Binding var showAlert: Bool // Binding to show/hide the alert
    @EnvironmentObject var userTypeManager: UserTypeManager

    var body: some View {
        Button(action: {
            showAlert.toggle()
        }) {
            Text("Logout")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(11)
        }
        .padding(.horizontal) // Add horizontal padding
        .padding(.bottom, 20) // Add bottom padding
            }
    
}

struct PatientProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let userTypeManager = UserTypeManager() // Create an instance of UserTypeManager
        userTypeManager.userID = "your_user_id_here" // Set the user ID
        
        return PatientProfileView()
            .environmentObject(userTypeManager) // Inject the environment object
    }
}
