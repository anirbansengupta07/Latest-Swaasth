import SwiftUI
import Firebase

struct DoctorInfoAppointmentTab: View {
    
    @Binding var appointments: [AppointmentModel]  // now this is a binding
    let appointment: AppointmentModel
    var backgroundColor: Color
    
    @State private var doctorName: String = "Loading..."
    @State private var specialisation: String = "Loading..."
    
    var body: some View {
        VStack {
            ZStack {
                backgroundColor
                    .opacity(0.8)
                    .frame(width: 360, height: 120)
                    .cornerRadius(10)
                
                HStack(spacing: 15) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                    
                    VStack(alignment: .leading){
                        Text(doctorName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(specialisation)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(appointment.formattedDate)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(appointment.timeSlot)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {
                        cancelAppointment()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.leading, 10)
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
            } else {
                print("No matching document found for DocID \(self.appointment.doctorID)")
                self.doctorName = "Doctor not found."
                self.specialisation = "Specialisation unknown."
            }
        }
    }
    
    private func cancelAppointment() {
        let db = Firestore.firestore()
        db.collection("appointments").document(appointment.id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                if let index = self.appointments.firstIndex(where: { $0.id == self.appointment.id }) {
                    DispatchQueue.main.async {
                        self.appointments.remove(at: index)
                    }
                }
            }
        }
    }
}
