//
//  DAddView.swift
//  HMS
//
//

import SwiftUI
import Firebase
import FirebaseStorage


struct DAddView: View {
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?

    @State private var dname: String = ""
    @State private var demp: String = ""
    @State private var demail: String = ""
    @State private var ddepartment: String = ""
    @State private var dpass: String = ""
    @State private var dspecialisationIndex = 0
    @State private var ddepartmentIndex = 0
    @State private var dcontact: String = ""
    @State private var dexperience: String = "1"
    @State private var ddegree: String = ""
    @State private var dcabin: String = ""
    @State private var dimage: String = ""
    @State private var isSpecialisationExpanded = false
    @State private var selectedExperienceIndex = 0
    @State private var isExperiencePickerPresented = false
    let yearsOfExperience: [Int] = Array(0...50)
    @State private var dexperienceIndex = 1
    @State private var showPicker = false
    
    @State private var showAlert = false // Control variable for showing alert
    @Environment(\.presentationMode) var presentationMode // Environment variable for controlling presentation mode
    
    let specializations: [DoctorModel.Specialization] = [
        .Cardiologist, .Orthopedic, .Endocrinologist,
        .Gastroenterologist, .Hematologist, .Neurologist,
        .Oncologist, .Orthopedist, .Pediatrician,
        .Psychiatrist, .Pulmonologist, .Rheumatologist,
        .Urologist, .Ophthalmologist, .Gynecologist
    ]
    let departments: [String] = [
        "Cardiology","Neurology","Oncology","Orthopedics","Endocrinilogy","Gastroenterology","Hematology","Pediatrics","Psychiatry","Pulmonology","Rheumatology","Urology","Ophthamology"
    ]
    

    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 20) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                            .onTapGesture {
                                isPickerShowing = true
                            }
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 120, height: 120)
                                .overlay(Image(systemName: "camera")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white))
                                .shadow(radius: 5)
                            
                            Text("Tap to select")
                                .foregroundColor(.white)
                                .font(.none)
                        }
                        .onTapGesture {
                            isPickerShowing = true
                        }
                    }
                }
                .padding()
                
                
                
                InputFieldView(data: $dname, title: "Name")
                InputFieldView(data: $demp, title: "Employee Id")
                InputFieldView(data: $demail, title: "Email")
                
                
                ZStack {
                    Picker("Department", selection: $ddepartmentIndex) {
                        ForEach(0..<departments.count) { index in
                            Text(departments[index])
                        }
                    }
                    .onChange(of: ddepartmentIndex) { newValue in
                        ddepartment = departments[newValue]
                    }
                    .accentColor(.black)
                    .pickerStyle(DefaultPickerStyle())
                    .frame(width: 360, height: 52) // Set frame size to match InputFieldView
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    HStack {
                        Text("Department")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 4)
                            .background(Color.white)
                        Spacer()
                    }
                    .padding(.leading, 18)
                    .offset(y: -25)
                }
                .padding(4)
                
                
                InputFieldView(data: $dpass, title: "Set Password")
                
                ZStack {
                    Picker("Specialisation", selection: $dspecialisationIndex) {
                        ForEach(0..<specializations.count) { index in
                            Text(specializations[index].rawValue)
                        }
                    }
                    .accentColor(.black)
                    .pickerStyle(DefaultPickerStyle())
                    .frame(width: 360, height: 52) // Set frame size to match InputFieldView
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    HStack {
                        Text("Specialisation")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 4)
                            .background(Color.white)
                        Spacer()
                    }
                    .padding(.leading, 18)
                    .offset(y: -25)
                }
                .padding(4)
                
                InputFieldView(data: $dcontact, title: "Contact")
                
                
                ZStack {
                    HStack {
                        TextField("", text: $dexperience)
                            .keyboardType(.decimalPad)
                            .onChange(of: dexperience) { newValue in
                                if dexperience.count > 2 {
                                    dexperience = String(dexperience.prefix(2))
                                }
                            }
                        Text("years")
                    }
                    .padding(.horizontal, 10)
                    .frame(width: 360, height: 52)
                    .overlay(
                        RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    HStack {
                        Text("Experience")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom,4)
                            .background(Color(Color.white))
                        Spacer()
                    }
                    .padding(.leading, 18)
                    .offset(CGSize(width: 0, height: -25))
                }.padding(4)
                InputFieldView(data: $ddegree, title: "Degree")
                InputFieldView(data: $dcabin, title: "Cabin No.")
                
                Button(action: {
                    uploadPhoto { urlString in
                        if let urlString = urlString {
                            print("Image uploaded successfully with URL: \(urlString)")
                        } else {
                            print("Failed to upload image")
                        }
                    }
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

            }
            .padding(.top, -50)
            .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePickerDoc(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Doctor added successfully"),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss() // Navigate back to StaffInfoView
                    }
                )
            }
        }
    }
    

    func uploadPhoto(completion: @escaping (String?) -> Void){
            guard let selectedImage = selectedImage else {
                return
            }
            
            let storageRef = Storage.storage().reference()
            let imageData = selectedImage.jpegData(compressionQuality: 0.8)
            
            guard let imageData = imageData else {
                return
            }
            
            let path = "Doctor/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(path)
            
            let uploadTask = fileRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error adding photo: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Image added successfully")
                    fileRef.downloadURL { url, error in
                        if let downloadURL = url {
                           dimage = downloadURL.absoluteString
                            setDoctorData()
                            print("Download URL: \(dimage)")
                            completion(dimage)
                        } else {
                            print("Error retrieving download URL: \(error?.localizedDescription ?? "Unknown error")")
                            completion(nil)
                        }
                    }
                }
          }
    }
    

    
    func setDoctorData() {
        let doctorData: [String: Any] = [
            "name": dname,
            "DocID": demp,
            "email": demail,
            "department": ddepartment,
            "specialisation": specializations[dspecialisationIndex].rawValue,
            "contact": dcontact,
            "experience": dexperience,
            "degree": ddegree,
            "cabin": dcabin,
            "image": dimage
        ]
        registerDoctor(doctorData: doctorData)
    }
    
    func registerDoctor(doctorData: [String: Any]) {
        guard let email = doctorData["email"] as? String,
              let password = dpass as? String else {  // Use the password from the form
            print("Invalid email or password")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error registering doctor \(email): \(error.localizedDescription)")
            } else if let authResult = authResult {
                let userUID = authResult.user.uid
                let userType = "doctor"
                // Set the user type
                addUserType(userUID: userUID, userType: userType)
                // Add doctor profile details, omitting the password for security reasons
                var profileData = doctorData
                profileData["authID"] = userUID  // Add the UID to the profile data
                addDoctorProfile(userUID: userUID, doctorData: profileData)
                print("Doctor registered and data added for \(email)")
                
                // Show success alert after doctor registration
                showAlert = true
            }
        }
    }
    
    func addUserType(userUID: String, userType: String) {
        let db = Firestore.firestore()
        let ref = db.collection("userType").document(userUID)
        ref.setData([
            "authID": userUID,
            "user": userType
        ]) { error in
            if let error = error {
                print("Error setting user type: \(error.localizedDescription)")
            } else {
                print("User type \(userType) added for UID: \(userUID)")
            }
        }
    }
    
    func addDoctorProfile(userUID: String, doctorData: [String: Any]) {
        var newDoctorData = doctorData
        newDoctorData["authID"] = userUID // Ensure the doctorData includes the authID
        
        let db = Firestore.firestore()
        db.collection("doctors").document() // Leave .document() empty for autoID
            .setData(newDoctorData) { error in
                if let error = error {
                    print("Error adding doctor profile: \(error.localizedDescription)")
                } else {
                    print("Doctor profile added for UID: \(userUID)")
                }
            }
    }
}


struct ImagePickerDoc: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPickerShowing: Bool
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerDoc
        
        init(parent: ImagePickerDoc) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.isPickerShowing = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPickerShowing = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need to update anything here
    }
}

struct DAddView_Previews: PreviewProvider {
    static var previews: some View {
        DAddView()
    }
}
