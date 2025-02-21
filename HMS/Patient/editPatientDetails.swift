//
//  editPatientDetails.swift
//  HMS
//


import SwiftUI

import Firebase

struct editPatientDetails: View {
    @State var patientData: PatientModel
    @EnvironmentObject var userTypeManager: UserTypeManager
    var title: String?
    @State private var gender = "Male"
    @State private var height = ""
    @State private var weight = ""
    @State private var bloodGroup = "AB-"
    @State private var address = ""
    @State private var emgContact = ""
    @State private var contact = ""
    @State private var name = ""
    
    @Binding var showEditSheet: Bool

    @State private var patientGenderIndex = 0
    @State private var patientBloodIndex = 0
    //  let fullName: String?
    let genders: [PatientModel.Gender] = [
        .male,.female,.others
    ]
    let bloods: [PatientModel.BloodGroup] = [
        .ABNegative,.ABPositive,.ANegative,.APositive,.BNegative,.BPositive,.ONegative,.OPositive
    ]
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    Text("Enter Details")
                        .font(.largeTitle)
                        .padding(.bottom)
                        .bold()
                
                    ZStack {
                        HStack {
                            TextField("Name", text: $name)
                                .keyboardType(.decimalPad)
                            
                        }
                        
                        .padding(.horizontal, 10)
                        .frame(width: 360, height: 52)
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        HStack {
                            Text(title ?? "Name")
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
                    
                    
                    ZStack {
                        Picker("BloodType", selection: $patientBloodIndex) {
                            ForEach(0..<bloods.count) { index in
                                Text(bloods[index].rawValue)
                                
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
                            Text("Blood Group")
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
                    
                    
                    ZStack {
                        HStack {
                            TextField("Height", text: $height)
                                .keyboardType(.decimalPad)
                            Text("cm")
                        }
                        
                        .padding(.horizontal, 10)
                        .frame(width: 360, height: 52)
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        HStack {
                            Text(title ?? "Height")
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
                    
                    
                    ZStack {
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                            Text("kgs")
                        }
                        .padding(.horizontal, 10)
                        .frame(width: 360, height: 52)
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        HStack {
                            Text(title ?? "Weight")
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
                    
                    
                    InputFieldView(data: $address, title: "Address")
                    InputFieldView(data: $contact, title: "Contact")
                    InputFieldView(data: $emgContact, title: "Emergency Contact")
                    
                    Button(action: {
                        updatePatientData()
                        editPatientData(patient: patientData)
                        self.showEditSheet.toggle()
                    }, label: {
                        Text("Continue")
                            .fontWeight(.heavy)
                            .font(.title3)
                            .frame(width: 300, height: 50)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(40)
                    })
                }.padding(.top,60)
                
            }
        }
    }
    func updatePatientData() {
        if !name.isEmpty {
            patientData.name = name
        }
        if !height.isEmpty {
            patientData.height = Float(height)
        }
        if !weight.isEmpty {
            patientData.weight = Float(weight)
        }
        if !address.isEmpty {
            patientData.address = address
        }
        if !emgContact.isEmpty {
            
            patientData.emergencyContact = emgContact
        }
        if !contact.isEmpty {
           
            patientData.contact = contact
        }
    }

    
    func editPatientData(patient: PatientModel) {
        let db = Firestore.firestore()
        let ref = db.collection("Patients").document(userTypeManager.userID)
        
        var updateData: [String: Any] = [
            "name": patient.name ?? "",
            "gender": patient.gender?.rawValue ?? "",
            "email": patient.email ?? ""
        ]
        
        if let name = patient.name {
            updateData["name"] = name
        }
        
        if let height = patient.height {
            updateData["height"] = height
        }
        if let weight = patient.weight {
            updateData["weight"] = weight
        }
        if let address = patient.address {
            updateData["address"] = address
        }
        if let contact = patient.contact {
            updateData["contact"] = contact
        }
        if let emergencyContact = patient.emergencyContact {
            updateData["emergencyContact"] = emergencyContact
        }
        
        ref.setData(updateData) { error in
            if let error = error {
                print("Error adding patient data: \(error.localizedDescription)")
            } else {
                print("Patient data successfully added")
                userTypeManager.userType = .patient
            }
        }
    }

}


