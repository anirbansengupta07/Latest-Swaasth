//
//  PdetailView.swift
//  HMS
//
//  Created by Sarthak on 23/04/24.
//

import SwiftUI
import Firebase

struct PdetailView: View {
    @State var patientData: PatientModel
    @EnvironmentObject var userTypeManager: UserTypeManager
    var title: String?
    @State private var gender = "Male"
    @State private var height = ""
    @State private var weight = ""
    @State private var bloodGroup = "AB-"
    @State private var address = ""
    @State private var emgContact = ""
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
                        .foregroundColor(.customBlue)
                    
                    ZStack {
                        Picker("Gender", selection: $patientGenderIndex) {
                            ForEach(0..<genders.count) { index in
                                Text(genders[index].rawValue)
                                
                            }
                        }
                        .accentColor(.customBlue)
                        .pickerStyle(DefaultPickerStyle())
                        .frame(width: 360, height: 52) // Set frame size to match InputFieldView
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                        HStack {
                            Text("Gender")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.customBlue)
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
                        Picker("BloodType", selection: $patientBloodIndex) {
                            ForEach(0..<bloods.count) { index in
                                Text(bloods[index].rawValue)
                                
                            }
                        }
                        .accentColor(.customBlue)
                        .pickerStyle(DefaultPickerStyle())
                        .frame(width: 360, height: 52) // Set frame size to match InputFieldView
                        .overlay(
                            RoundedRectangle(cornerRadius: 11)
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                        HStack {
                            Text("Blood Group")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.customBlue)
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
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                        HStack {
                            Text(title ?? "Height")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.customBlue)
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
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                        HStack {
                            Text(title ?? "Weight")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundColor(Color.customBlue)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom,4)
                                .background(Color(Color.white))
                            Spacer()
                        }
                        .padding(.leading, 18)
                        .offset(CGSize(width: 0, height: -25))
                    }.padding(4)
                    
                    
                    InputFieldView(data: $address, title: "Address")
                    InputFieldView(data: $emgContact, title: "Emergency Contact")
                    
                    Button(action: {
                        updatePatientData()
                        addPatientData(patient: patientData)
                    }, label: {
                        Text("Continue")
                            .fontWeight(.heavy)
                            .font(.title3)
                            .frame(width: 300, height: 50)
                            .foregroundColor(.white)
                            .background(Color.customBlue)
                            .cornerRadius(11)
                    })
                }.padding(.top,60)
                
            }
        }
    }
    func updatePatientData() {
            patientData.name = patientData.name ?? ""
        patientData.gender = genders[patientGenderIndex]
            patientData.height = Float(height)
            patientData.weight = Float(weight)
            patientData.bloodGroup = bloods[patientBloodIndex]
            patientData.address = address
            patientData.contact = emgContact
            patientData.emergencyContact = emgContact
        }
    
    func addPatientData(patient: PatientModel) {
        let db = Firestore.firestore()
        let ref = db.collection("Patients").document(userTypeManager.userID)
        ref.setData([
            "name": patient.name!,
            "gender": patient.gender!.rawValue,
            "height": patient.height!,
            "weight": patient.weight!,
            "bloodGroup": patient.bloodGroup!.rawValue,
            "address": patient.address!,
            "contact": patient.contact!,
            "email": patient.email!,
            "emergencyContact": patient.emergencyContact!
        ]) { error in
            if let error = error {
                print("Error adding patient data: \(error.localizedDescription)")
            } else {
                print("Patient data successfully added")
                userTypeManager.userType = .patient
            }
        }
    }
}


//#Preview {
//    PdetailView(patientData: PatientModel, userTypeManager: UserTypeManager, title: <#T##String?#>, gender: <#T##arg#>, height: <#T##arg#>, weight: <#T##arg#>, bloodGroup: <#T##arg#>, address: <#T##arg#>, emgContact: <#T##arg#>, patientGenderIndex: <#T##arg#>, patientBloodIndex: <#T##arg#>)
//}
//
