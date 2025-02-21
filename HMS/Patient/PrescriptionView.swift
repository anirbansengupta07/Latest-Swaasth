import SwiftUI
import FirebaseFirestore

struct PrescriptionView: View {
    @State private var prescriptionData: PrescriptionModel?
    var appointment: AppointmentModel
    @StateObject private var viewModel = PrescriptionViewModel()

    var body: some View {
        NavigationView {
            Form {
                //ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Description:")
                            .font(.headline)
                        Text(prescriptionData?.description ?? "Description not available")
                            .font(.body)
                        
                        Divider()
                        
                        Text("Prescribed Medicine:")
                            .font(.headline)
                        ForEach(prescriptionData?.prescribedMedicines.keys.sorted() ?? [], id: \.self) { medicineName in
                            if let medicineDetails = prescriptionData?.prescribedMedicines[medicineName] {
                                Text("\(medicineName): \(medicineDetails.dosage) - \(medicineDetails.intakePattern.map { $0.rawValue }.joined(separator: ", "))")
                            }
                        }
                        
                        Divider()
                        
                        Text("Prescribed Tests:")
                            .font(.headline)
                        ForEach(prescriptionData?.prescribedTest ?? [], id: \.self) { test in
                            Text(test)
                        }
                        
                        Divider()
                        
                        Text("Prescribed Treatment:")
                            .font(.headline)
                        Text(prescriptionData?.prescription ?? "Prescription not available")
                            .font(.body)
                        
                        Spacer()
                    }
                    .padding()
                //}
            }
            //.navigationBarTitle("Prescription", displayMode: .inline)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationTitle("Prescription")
        .onAppear {
            fetchPrescriptionData()
        }
    }

    private func fetchPrescriptionData() {
        let db = Firestore.firestore()
        let prescriptionsRef = db.collection("prescriptions")
        
        prescriptionsRef.whereField("appointmentID", isEqualTo: appointment.id)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching prescription data: \(error.localizedDescription)")
                } else {
                    guard let documents = querySnapshot?.documents, let firstDocument = documents.first else {
                        print("No prescription data found for appointmentID: \(appointment.id)")
                        return
                    }
                    
                    if let prescriptionData = PrescriptionModel(dictionary: firstDocument.data(), id: firstDocument.documentID) {
                        self.prescriptionData = prescriptionData
                    } else {
                        print("Error decoding prescription data: Missing required fields")
                    }
                }
            }
    }
}
