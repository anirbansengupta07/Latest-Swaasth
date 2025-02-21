//
//  appointments-completed.swift
//  HMS
//


import SwiftUI
import Firebase


struct CompletedAppointmentView: View {
    var appointment: AppointmentModel
    @State private var doctorName: String = "Loading..."
    @State private var specialisation: String = "Loading..."
    @State private var doctorImageURL: String? = nil
    
    var body: some View {
        ZStack{
            HStack{
                
                if let urlStr = doctorImageURL, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { image in
                                        image.resizable().clipShape(RoundedRectangle(cornerRadius: 11.0)).frame(width: 100, height: 120)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(10)
                                } else {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 100, height: 130)
                                        .cornerRadius(30)
                                        .padding(.leading, 60)
                                }
                VStack(alignment: .leading) {
                    Text(doctorName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text(specialisation)
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Date: \(appointment.formattedDate)")
                        .font(.subheadline)
                    Text("Time: \(appointment.timeSlot)")
                        .font(.subheadline)
                    Text("AppointmentID: \(appointment.id)")
                        .font(.subheadline)
//                    Button(action: {
////                        cancelAppointment()
//                    }) {
//                        Text("View Prescription")
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 16)
//                            .background(Color.customBlue)
//                            .cornerRadius(8)
//                    }
                    NavigationLink("View Prescription", destination: PrescriptionView(appointment: appointment))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.customBlue)
                        .cornerRadius(8)

                }
            }
                .padding()
                .background(Color.white)
                .frame(width: 350,height: 200)
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.bottom)
                .padding(.leading)
                .padding(.trailing)
            }
        .onAppear {
            fetchDoctorDetails()
        }

        }
    
    private func fetchDoctorDetails() {
        let db = Firestore.firestore()
        let doctorsRef = db.collection("doctors")
        
        doctorsRef.whereField("DocID", isEqualTo: appointment.doctorID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching doctor details: \(error.localizedDescription)")
                self.doctorName = "Doctor details could not be loaded."
                self.specialisation = "Please try again later."
            } else if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                guard let data = querySnapshot.documents.first?.data() else {
                    self.doctorName = "Doctor not found."
                    self.specialisation = "Specialisation unknown."
                    return
                }
                
                self.doctorName = data["name"] as? String ?? "No name available"
                self.specialisation = data["specialisation"] as? String ?? "No specialisation available"
                self.doctorImageURL = data["image"] as? String
            } else {
                print("No matching document found for DocID \(self.appointment.doctorID)")
                self.doctorName = "Doctor not found."
                self.specialisation = "Specialisation unknown."
            }
        }
    }
}
//    .onAppear {
//        PrescriptionManager.shared.fetchPrescription(patientId: appointment.patientID) { fetchedPrescription in
//            self.prescription = fetchedPrescription
//        }
//    }
